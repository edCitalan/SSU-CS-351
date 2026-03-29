# Project 1 - Performance Analysis Report

## Which program is fastest? Is it always the fastest?

**alloca** and **malloc** are consistently the fastest programs. At 1M blocks with `-O2` optimization and default data sizes (MIN_BYTES=3, MAX_BYTES=100), alloca averaged 0.139s and malloc averaged 0.154s. With small data sizes (MIN_BYTES=10, MAX_BYTES=10), alloca was the clear winner at 0.070s vs malloc at 0.087s.

alloca is fastest because it allocates memory on the stack rather than the heap. Stack allocation is essentially just a pointer adjustment — there's no need to search for free memory or manage metadata the way heap allocators do. However, alloca is not always the fastest. With large data sizes (MIN_BYTES=1000, MAX_BYTES=5000), malloc (5.939s) slightly edges out alloca (6.315s), because the large stack frames from recursion start to cause overhead.

## Which program is slowest? Is it always the slowest?

**list** is generally the slowest program. At 1M blocks with `-O2` and default sizes, list averaged 0.208s. With large data sizes, list averaged 7.201s, the worst of all four.

list is slowest because `std::list` adds overhead from its doubly-linked list management, including extra pointer storage and more heap allocations per node compared to the manual implementations. new is close behind list in most tests (0.198s vs 0.208s at default sizes), since it also uses heap allocation via `operator new`, but with less container overhead.

## Was there a trend in program execution time based on the size of data in each Node?

Yes. As node data size increases, all programs slow down significantly:

| Configuration | alloca | list | malloc | new |
|---|---|---|---|---|
| MIN=10, MAX=10, 1M blocks | 0.070s | 0.136s | 0.087s | 0.135s |
| MIN=3, MAX=100, 1M blocks | 0.139s | 0.208s | 0.154s | 0.198s |
| MIN=1000, MAX=5000, 1M blocks | 6.315s | 7.201s | 5.939s | 6.620s |

Larger data per node means more bytes to allocate, initialize (via `std::iota`), and hash. The hashing loop iterates over every byte, so larger nodes directly increase computation time. Memory usage also scales dramatically — from ~55MB at small sizes to ~3.4GB at large sizes.

## Was there a trend in program execution time based on the length of the block chain?

Yes. Longer chains mean more nodes to allocate and hash, so runtime scales roughly linearly with NUM_BLOCKS. At 10K blocks with `-O2`, all programs ran in under 0.01s. At 1M blocks, times ranged from 0.139s (alloca) to 0.208s (list). The relative ordering of programs stays mostly consistent across chain lengths.

## Consider heap breaks — what's noticeable? Does increasing the stack size affect the heap?

| NUM_BLOCKS | alloca | list | malloc | new |
|---|---|---|---|---|
| 10,000 | 69 | 78 | 76 | 78 |
| 1,000,000 | 69 | 933 | 751 | 933 |
| 10,000,000 | 69 | 8,711 | 6,888 | 8,711 |

**alloca stays at 69 breaks regardless of chain length** because it allocates on the stack, not the heap. The heap doesn't grow as more nodes are added. This is the most striking observation.

list and new have identical break counts because both use heap allocation for each node — list via `std::list` internals and new via `operator new`. malloc has fewer breaks than list/new because `malloc()` may have slightly different allocation patterns or less per-node overhead.

Increasing the stack size (via `ulimit -s unlimited`) does not affect the heap — it only allows alloca to use more stack space without crashing. The heap and stack are separate memory regions.

## Node Diagram (malloc/alloca version)

Consider a Node that allocated 6 bytes of data:

```
head ──► ┌──────────────────────────┐
         │ Node                     │
         │  next ──────────────►  ──┼──► (next Node or nullptr)
         │  numBytes: 6            │
         │  bytes ─────► [0][1][2][3][4][5]  (6 bytes, values 1-6)
         │               ▲                    │
         │               │                    │
         │               bytes pointer points │
         │               to first byte        │
         └──────────────────────────┘
                                    ▲
                                    │
tail ───────────────────────────────┘  (if last node)
```

**Size of a Node with 6 bytes of data:**
- `next` pointer: 8 bytes (64-bit system)
- `numBytes` (Size/unsigned int): 4 bytes
- `bytes` pointer: 8 bytes
- Allocated data: 6 bytes
- **Total: ~26 bytes** (plus potential alignment padding from malloc)

The `head` pointer points to the first node in the list. The `tail` pointer points to the last node. Each node's `next` pointer points to the following node (or nullptr for the last node). The `bytes` pointer points to the first byte of the separately allocated data array.

## Were any tasks the same across programs? Which were different?

**Same across all programs:**
- Data initialization (`std::iota` filling bytes 1 through n)
- Hashing algorithm (same multiplier, same logic)
- Output and verification

**Different:**
- **Memory allocation:** This is the key difference. list uses `std::list` (heap, with container overhead). new uses `operator new` (heap). malloc uses `malloc()` (heap, C-style). alloca uses `alloca()` (stack, via recursion).
- **List construction:** list uses `std::list::push_back`. The other three manually manage a singly-linked list with head/tail pointers.
- **Traversal:** list uses `std::list` iterators. The others walk the `next` pointer chain.

## As data size increases, does the significance of allocating the node increase or decrease?

It **decreases**. When nodes are small, the overhead of allocation (finding free memory, updating metadata, system calls) is a significant fraction of the total work per node. When nodes are large, the time spent initializing and hashing the data dominates, and the allocation overhead becomes proportionally smaller.

This is visible in the data: with small nodes (MIN=10, MAX=10), alloca (0.070s) is nearly 2x faster than list (0.136s) — allocation overhead matters a lot. With large nodes (MIN=1000, MAX=5000), alloca (6.315s) vs list (7.201s) is only about a 14% difference — the hashing computation dominates and allocation overhead is less significant.

## Compiler Optimization Effects

Optimization with `-O2` dramatically improved performance:

| Program | Unoptimized (-g) avg | Optimized (-O2) avg | Speedup |
|---|---|---|---|
| alloca | 0.009s | 0.000s | >9x |
| list | 0.020s | 0.005s | 4x |
| malloc | 0.008s | 0.000s | >8x |
| new | 0.018s | 0.004s | ~4.5x |

(At 10K blocks — times are very small, so ratios are approximate)

The optimizer eliminates unnecessary memory operations, inlines functions, and can vectorize the hashing loop, resulting in significant speedups across all programs.
