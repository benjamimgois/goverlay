
# Vulkan memory management in PasVulkan

Memory management in Vulkan is a complex and intricate process that gives developers control over how graphics memory is allocated and used. The primary principle of Vulkan's memory management is that it offers a lower-level interface to the GPU than APIs like OpenGL, entrusting developers with the responsibility of managing memory allocations themselves. This can lead to more efficient use of memory and enhanced performance, but it also necessitates a deeper understanding of how the GPU operates and the optimal way to manage its resources.

In Vulkan, memory is organized in a hierarchy that includes heaps, memory types, and memory property flags. Heaps are fixed-size memory resources exposed by the device, and each heap can support different memory types. When creating a resource like a buffer, Vulkan provides information about which memory types are compatible with that resource. Depending on the resource's usage flags, the developer must select the right memory type and, based on that type, the appropriate heap.

Memory can be host-visible (accessible by the CPU and potentially slower) or device-local (residing on the GPU and generally faster but not host-visible). The latter type of memory often requires the use of a staging resource or the GPU itself to write data to it. Many new systems with Unified Memory Architecture (UMA) and/or PCIe Resizable BAR (ReBAR) support can have both cases simultaneously.

Vulkan requires developers to manage memory alignment and address the possibility that different resources may alias (share) the same region of memory. Resources may also need to be sub-allocated, where a larger allocation is partitioned into smaller ones. This enables efficient reuse of existing allocations and improved cache utilization.

Libraries like the Vulkan Memory Allocator (VMA) by GPUOpen/AMD, which provide higher-level functions to assist with Vulkan memory management, do exist. VMA offers functionalities like choosing the correct and optimal memory type based on intended usage, allocating memory blocks and reserving parts of them, and creating an image/buffer, allocating memory for it, and binding them together - all in one call.

However, PasVulkan uses its own custom memory management, which predates the first public release of VMA. It manages Vulkan memory by working with memory blocks and memory chunks. A memory block is a small region within one allocation, and a memory chunk is a memory region that encompasses a list of blocks and represents a single allocation. A chunk can allocate a block, deallocate a block, and check if a block is within the chunk. A chunk allocates its memory within the constructor, and when a deallocation occurs, it merely marks the block as free. Memory alignment is automatically managed in PasVulkan's allocation process.

## The core idea

The allocation policy in PasVulkan employs a memory management algorithm that uses two red-black trees to manage free memory blocks within a heap: One sorted by address and another by size.

To comprehend the effectiveness of PasVulkan's allocation policy, we need to scrutinize its key operations: allocation, deallocation, and reallocation.

1. **Allocation:** The algorithm initially searches the size tree for the smallest block that is equal to or larger than the required size. If the found block is larger than the necessary size, it's divided into two blocks: the larger block is returned to the size tree for future allocations, and the smaller block of the required size is returned to the caller. If the block found is precisely the required size, it's removed from both trees and returned to the caller. If a sufficient block isn't found, a new Vulkan heap block is allocated, and the whole operation is repeated. The time complexity for these operations is O(log n) due to the search and insertion operations in the red-black trees.

2. **Deallocation:** The deallocated memory blocks are returned to the address tree. Each node along the path to the insertion point for the new node is examined to see if it adjoins the node being inserted. If so, the nodes are merged, and the merged node is relocated in the size tree. If not, the node is inserted in both trees. After insertion, the trees are checked for correct balancing. Once again, these operations are performed in O(log n) time.

3. **Reallocation (not implemented in this use case):** If the size of the reallocated block is larger than the original block, the original block is returned to the free trees so that any possible coalescence can occur. A new block of the requested size is then allocated, the data is moved from the original block to the new block, and the new block is returned to the caller. If the size of the reallocated block is smaller than the original block, the block is split, and the remainder is returned to the free tree. The time complexity for these operations is also O(log n).

## Advantages

PasVulkan's allocation policy possesses a few key advantages:

1. **Fast operations:** The use of red-black trees guarantees that all primary operations (allocation, deallocation, and reallocation) have a time complexity of O(log n), which is efficient for a large number of nodes. Red-black trees are self-balancing binary search trees, which means that they maintain their balance after insertions and deletions, ensuring that no path in the tree is more than twice as long as any other. This feature is crucial for rapid execution of tree operations.

2. **Efficient use of memory:** The algorithm endeavors to find the smallest possible block that meets the size requirement, which can help minimize memory waste. During memory deallocation, the algorithm checks if the block adjoins another free block and merges them if possible, which can help avert fragmentation and optimize memory use.

3. **Scalability:** PasVulkan's allocation policy can efficiently handle the expansion of the heap by adding the expanded block to the size and address trees and continuing the allocation process as before.

## Drawbacks

However, it's crucial to note that this policy also has some potential drawbacks:

1. **Overhead:** The use of two red-black trees for managing memory can introduce some overhead, both in terms of memory (for maintaining the tree structures) and time (for performing tree operations). This overhead may not be a concern for applications with ample memory and CPU power, but it could be significant for more constrained environments.

2. **Memory fragmentation:** Although PasVulkan's allocation policy attempts to minimize fragmentation by merging adjoining free blocks during deallocation, it cannot completely prevent fragmentation. When blocks of memory are allocated and deallocated randomly, it can lead to a situation where the memory is divided into small, non-contiguous free blocks, even if the total amount of free memory is sufficient for a requested allocation. This fragmentation can render memory use inefficient and potentially lead to allocation failures.

3. **Complications with reallocation (which can be negligible here, since PasVulkan does not yet implement real reallocation at the GPU memory level):** When reallocating memory, the original block is freed, and a new block is allocated. This process involves moving the data from the original block to the new block, which can be time-consuming for large amounts of data. Moreover, if the memory has become fragmented, it may be challenging to find a large enough contiguous block for the reallocation, leading to allocation failures or the need to allocate another new native Vulkan heap block.

## Conclusion

Despite these potential drawbacks, PasVulkan's allocation policy can be an effective memory management strategy for many applications. Its use of red-black trees to manage memory can provide efficient allocation and deallocation operations, and its strategies for finding the smallest sufficient block and merging adjoining free blocks can contribute to efficient memory use.

The effectiveness of PasVulkan's allocation policy can vary depending on the specific requirements and constraints of the application, including the amount of available GPU memory, the frequency and size of allocation and deallocation operations, and the tolerance for overhead. Of course, other allocation policies exist, such as stack allocators, ring buffer-like allocators, and TLSF, which can potentially outperform PasVulkan's allocation policy in many situations. These policies justify their existence through their performance/benefit ratios, but PasVulkan's allocation policy aims to be generally applicable. It's also possible that PasVulkan will support other more specialized fine-tuned allocation policies in the future. After all, one never knows what the future holds. :-)

