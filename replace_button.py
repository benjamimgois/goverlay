import sys

def replace_button_in_lfm():
    lines = []
    with open('/home/benjamim/Documentos/goverlay/overlayunit.lfm', 'r') as f:
        lines = f.readlines()
    
    with open('/home/benjamim/Documentos/goverlay/overlayunit.lfm', 'w') as f:
        in_button = False
        for line in lines:
            if 'object protontricksManagerButton: TButton' in line:
                f.write(line.replace('TButton', 'TBitBtn'))
            else:
                f.write(line)

replace_button_in_lfm()
