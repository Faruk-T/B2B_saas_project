## Goal
Day D8 — Multi-sector business engines. Order and pricing strategies per industry vertical.

## Playbook
[Phase 2 — Section 2.3 (D8)](../playbooks/phase-2-detailed.md#bölüm-23--gün-d8-çok-sektörlü-iş-motorları)

## Branch
`phase-2/section-3-sector-engines`

## Tasks
- [ ] Textile — `MatrixOrderStrategy` (color × size grid)
- [ ] Automotive — `FitmentEngine` (OEM, brand/model/year)
- [ ] FMCG — `BatchLotDriver` (batch, expiry date)
- [ ] Construction — `CalculatesByDimensionStrategy` (m²/m³/kg)
- [ ] `SectorEngineFactory` — tenant sector → strategy resolver

## Acceptance criteria
- [ ] At least one validation test per sector strategy
- [ ] Factory resolves correct strategy for tenant sector profile

## Example commits
```
feat(sector): add MatrixOrderStrategy for textile color-size grid
feat(sector): add FitmentEngine for automotive OEM matching
feat(sector): add BatchLotDriver and dimension-based pricing strategies
feat(sector): add SectorEngineFactory with sector resolution tests
```
