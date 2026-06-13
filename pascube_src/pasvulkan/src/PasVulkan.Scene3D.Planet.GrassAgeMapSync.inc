(*******************************************************************************
 *                                 PasVulkan                                   *
 *******************************************************************************
 * A/B fix toggle for the cross-queue SYNC-HAZARD-WRITE-RACING-WRITE on the    *
 * master grass age map (TpvScene3DPlanet.TData[-1].fGrassAgeMapImage).        *
 *=============================================================================*
 *                                                                             *
 * The master grass age map is written every frame by BOTH the universal       *
 * queue (GrassAgeMapUpdate / GrassAgeMapSandboxGrowth / GrassFlagsMapFlags-   *
 * Update in TpvScene3D.ProcessFrame) AND the update queue (grass age          *
 * modifications + TpvScene3DPlanet.TData.TransferTo). The update queue is     *
 * carved from the universal queue family (see TpvVulkanDevice update queue    *
 * selection), so both are the SAME queue family but DIFFERENT VkQueues -      *
 * therefore this is a missing cross-queue execution+memory dependency, NOT a  *
 * queue-family-ownership-transfer problem (a QFOT within one family is a      *
 * no-op and would not resolve it).                                            *
 *                                                                             *
 * Choose exactly ONE of the two approaches below for A/B comparison (comment  *
 * one, uncomment the other):                                                  *
 *                                                                             *
 *  PasVulkanPlanetGrassAgeMapSyncSemaphore (B, default):                      *
 *    The universal-queue ProcessFrame submit signals a dedicated timeline     *
 *    semaphore after the grass-age-map passes; the update queue host-waits on *
 *    that timeline value before recording TransferTo (mirrors the existing    *
 *    TpvScene3DPlanet.WaitOnceOnPreviousFrameForCheck pattern). Pure added    *
 *    synchronization - no change to where the work runs or to its timing.     *
 *                                                                             *
 *  PasVulkanPlanetGrassAgeMapSyncConsolidate (A):                             *
 *    The grass-age-map passes are recorded on the update queue (where the     *
 *    grass age modifications and TransferTo already run) instead of on the    *
 *    universal queue, so all master-grass-age-map access lives on a single    *
 *    queue and ordinary pipeline barriers fully synchronize it - the          *
 *    cross-queue race is removed entirely.                                    *
 *    Note: approach A assumes the update queue belongs to a graphics-capable  *
 *    (universal) queue family, since GrassFlagsMapFlagsUpdate uses an         *
 *    ALL_GRAPHICS destination barrier stage. That holds on the repro device   *
 *    (the update queue is carved from the universal family). Approach B has   *
 *    no such assumption.                                                      *
 *                                                                             *
 *******************************************************************************)

{$define PasVulkanPlanetGrassAgeMapSyncSemaphore}
{.$define PasVulkanPlanetGrassAgeMapSyncConsolidate}

// Consolidate (A) wins if both happen to be defined, so the two approaches stay
// mutually exclusive regardless of how the toggles above are edited.
{$ifdef PasVulkanPlanetGrassAgeMapSyncConsolidate}
 {$undef PasVulkanPlanetGrassAgeMapSyncSemaphore}
{$endif}
