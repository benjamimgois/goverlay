import numpy as np
import torch
import sys
from torch import nn
from torch import optim
from numpy.random import Generator, PCG64, SeedSequence

# Set device to GPU if available
if torch.cuda.is_available(): 
    dev = "cuda:0" 
    torch.set_default_tensor_type('torch.cuda.FloatTensor')
else: 
    dev = "cpu" 
torch.cuda.set_device(dev)

def blendBackToFront(target, source):
    oneMinusSourceAlpha = 1.0 - source[3]
    result = np.zeros(4)
    result[0] = (target[0] * oneMinusSourceAlpha) + (source[0] * source[3])
    result[1] = (target[1] * oneMinusSourceAlpha) + (source[1] * source[3])
    result[2] = (target[2] * oneMinusSourceAlpha) + (source[2] * source[3])
    result[3] = (target[3] * oneMinusSourceAlpha) + source[3]
    return result
    
def blendFrontToBack(target, source):
    oneMinusTargetAlpha = 1.0 - target[3]
    weight = oneMinusTargetAlpha * source[3]
    result = np.zeros(4)
    result[0] += source[0] * weight
    result[1] += source[1] * weight
    result[2] += source[2] * weight
    result[3] += weight
    return result

# Generate training data
print('Generating training data...')
trainingSet = []
for countColors in range(3, 16):
    countMinusTwo = countColors - 2
    for colorSetVariantIndex in range(65536):
        
        # Compute color set for the current permutation for the current color count
        #colors = np.zeros((countColors, 4))
        #rg = Generator(PCG64(SeedSequence(colorSetVariantIndex + (countColors * 65536))))
        #for i in range(countColors):
        #    colors[i] = rg.random(4)
        colors = np.clip(np.random.rand(countColors, 4), 0.0, 1.0) 

        # Compute average color and alpha
        averageColor = np.zeros(4)
        for i in range(2, colors.shape[0]):
            averageColor += colors[i]
        averageColor /= countMinusTwo

        # Compute accumulated premultiplied alpha color
        accumulatedPremultipliedAlphaColor = np.array([0.0, 0.0, 0.0, 1.0])
        for i in range(colors.shape[0]):
            accumulatedPremultipliedAlphaColor[:3] += colors[i, :3] * colors[i, 3]
            accumulatedPremultipliedAlphaColor[3] *= 1.0 - colors[i, 3]

        # Compute correct OIT color for the two front fragments
        correctOITColor = np.zeros(4)
        for i in range(2):
            correctOITColor = blendFrontToBack(correctOITColor, colors[i])
        
        # Compute correct OIT color for all fragments
        totalOITColor = np.zeros(4)
        for i in range(colors.shape[0]):
            totalOITColor = blendFrontToBack(totalOITColor, colors[i])
        
        # Add training sample
        trainingSample = {}
        trainingSample['inputs'] = np.zeros(10)
        trainingSample['targets'] = np.zeros(3)
        trainingSample['inputs'][0] = averageColor[3]
        trainingSample['inputs'][1] = averageColor[0]
        trainingSample['inputs'][2] = averageColor[1]
        trainingSample['inputs'][3] = averageColor[2]
        trainingSample['inputs'][4] = accumulatedPremultipliedAlphaColor[0]
        trainingSample['inputs'][5] = accumulatedPremultipliedAlphaColor[1]
        trainingSample['inputs'][6] = accumulatedPremultipliedAlphaColor[2]
        trainingSample['inputs'][7] = correctOITColor[0]
        trainingSample['inputs'][8] = correctOITColor[1]
        trainingSample['inputs'][9] = correctOITColor[2]
        trainingSample['targets'][0] = totalOITColor[0]
        trainingSample['targets'][1] = totalOITColor[1]
        trainingSample['targets'][2] = totalOITColor[2]
        trainingSet.append(trainingSample)
print('Finished generating training data!')

# save training set to file
print('Saving training data to file...')
with open('trainingdata.txt', 'w') as file:
    for trainingSample in trainingSet:
        file.write(str(list(trainingSample['inputs'])).replace('[', '').replace(']', '').replace(',', '') + ' ' + str(list(trainingSample['targets'])).replace('[', '').replace(']', '').replace(',', '') + '\n')
    file.close()
print('Finished saving training data to file!')

# Load training data from file again back
#data = np.loadtxt('trainingdata.txt')
#inputs = data[:, :10]
#targets = data[:, 10:]

# Convert training data to numpy arrays
print('Converting training data to numpy arrays...')
inputs = np.zeros((len(trainingSet), 10))
targets = np.zeros((len(trainingSet), 3))
for i in range(len(trainingSet)):
    inputs[i] = trainingSet[i]['inputs']
    targets[i] = trainingSet[i]['targets']
print('Finished converting training data to numpy arrays!')

print('Training network...')

# Convert data to PyTorch tensors
inputs_tensor = torch.tensor(inputs, dtype=torch.float32)
targets_tensor = torch.tensor(targets, dtype=torch.float32)

# Define the network architecture
class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        self.fc1 = nn.Linear(10, 32)
        self.fc2 = nn.Linear(32, 16)
        self.fc3 = nn.Linear(16, 3)

    def forward(self, x):
        x = torch.relu(self.fc1(x))
        x = torch.relu(self.fc2(x))
        x = torch.sigmoid(self.fc3(x))
        return x

# Instantiate the network
net = Net()

# Define the loss function and the optimizer
criterion = nn.MSELoss()
optimizer = optim.Adam(net.parameters(), lr=0.00001)

# Training loop
for epoch in range(65536):  # Loop over the dataset multiple times
    # Zero the parameter gradients
    optimizer.zero_grad()

    # Forward + backward + optimize
    outputs = net(inputs_tensor)
    loss = criterion(outputs, targets_tensor)
    loss.backward()
    optimizer.step()

    # Print statistics
    sys.stdout.write(f'\rEpoch {epoch + 1}, Loss: {loss.item()}')
    sys.stdout.flush()

sys.stdout.write(f'\n')
sys.stdout.flush()
print('Finished Training')

# Save the trained model
torch.save(net.state_dict(), 'trained_model.pth')

print('Generating GLSL code...')
# Output GLSL arrays
with open('dfaoit_network.glsl', 'w') as file:
    file.write(f'// dfaoit_network.glsl\n');
    file.write(f'// This file was automatically generated by dfaoittrain\n\n');
    for i, layer in enumerate(net.children()):
        weights = layer.weight.cpu().detach().numpy()
        biases = layer.bias.cpu().detach().numpy()

        # Generate GLSL code for declaring weights
        file.write(f'// Layer {i + 1}\n')
        file.write(f'#define LAYER{i + 1}_WEIGHTS_COUNT {len(weights)}\n')
        file.write(f'#define LAYER{i + 1}_WEIGHTS_SIZE {weights.shape[1]}\n')
        file.write(f'\n')
        file.write(f'const float weights{i + 1}[{len(weights)}][{weights.shape[1]}] = {{\n')
        for j in range(len(weights)):
            file.write(f'  {{\n')
            weightLine = weights[j]
            for k in range(len(weightLine)):
                weight = weightLine[k]
                file.write('    ' + str(weight));
                if k != len(weightLine) - 1:
                    file.write(',')
                file.write('\n')
            file.write('  }')
            if j != len(weights) - 1:
                file.write(',')
            file.write('\n')   
        file.write('};\n\n')

        # Generate GLSL code for declaring biases
        file.write(f'const float biases{i + 1}[{len(biases)}] = {{\n')    
        for j in range(len(biases)):
            bias = biases[j] 
            file.write('  ' + str(bias));
            if j != len(biases) - 1:
                file.write(',')
            file.write('\n') 
        file.write('};\n\n')
    file.close()

print('Finished generating GLSL code!')