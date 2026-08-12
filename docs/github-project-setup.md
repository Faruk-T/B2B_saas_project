# GitHub Proje Mimarisi — Kanban, Labels, Milestones, Issues

**Repo:** [Faruk-T/B2B_saas_project](https://github.com/Faruk-T/B2B_saas_project)

Bu rehber, onay beklerken GitHub tarafındaki **operasyonel mimariyi** kurman içindir.

---

## Ekip rol dağılımı (onay akışı)

```
Faruk (sen)
  │  Günün görevini bitir → branch push → PR aç
  │  Merge YAPMAZ ❌
  ▼
Collaborator 1 + Collaborator 2
  │  Kodu inceler → Approve ✅ (2 onay gerekli)
  ▼
Ümit Bey
  │  Final review → Merge ✅
  ▼
main branch güncellenir → sonraki gün D(n+1)
```

| Rol | Yetki |
|-----|-------|
| **Faruk** | Branch aç, commit, push, PR oluştur, issue güncelle |
| **Collaborator ×2** | PR review, Approve / Request changes |
| **Ümit Bey** | Final merge to `main`, branch protection ayarları |

---

## Adım 1 — Labels (12 adet)

GitHub → **Issues** → **Labels** → New label

| Label | Renk | Açıklama |
|-------|------|----------|
| `phase-1` | `#0E8A16` | D1–D5 |
| `phase-2` | `#1D76DB` | D6–D10 |
| `phase-3` | `#5319E7` | D11–D15 |
| `phase-4` | `#FBCA04` | D16–D20 |
| `backend` | `#C5DEF5` | Laravel |
| `frontend` | `#BFD4F2` | Flutter |
| `infra` | `#D4C5F9` | Docker, CI |
| `docs` | `#0075CA` | Dokümantasyon |
| `test` | `#006B75` | Testler |
| `day-task` | `#F9D0C4` | Günlük görev |
| `in-review` | `#FEF2C0` | PR açık, onay bekliyor |
| `blocked` | `#B60205` | Blokeli |

**Hızlı kurulum (terminal):**
```powershell
gh auth login
cd "c:\Users\user\Desktop\Trunçgil Commerce OS\b2b-main"
.\scripts\setup-github-project.ps1
```

---

## Adım 2 — Milestones (4 adet)

GitHub → **Issues** → **Milestones** → New milestone

| Başlık | Açıklama |
|--------|----------|
| `M1 — Phase 1 Foundation & Tenancy` | D1–D5 |
| `M2 — Phase 2 Core Domain & Catalog` | D6–D10 |
| `M3 — Phase 3 Async & Integrations` | D11–D15 |
| `M4 — Phase 4 Flutter Client` | D16–D20 |

Due date isteğe bağlı (ör. her milestone +5 iş günü).

---

## Adım 3 — Issues (20 adet)

Her gün = 1 issue. Tam liste: [`github-roadmap.md`](github-roadmap.md)

Issue body şablonları: `docs/issue-bodies/D1-planning-readme.md` … `D20-release.md`

**Manuel:** Issues → New issue → başlık + label + milestone + body yapıştır

**Otomatik:** `.\scripts\setup-github-project.ps1` (gh auth gerekli)

### D1 issue (şu anki PR ile bağla)

PR açarken description'a yaz:
```
Closes #1
Phase: 1
Section: 1.1
Day: D1
```

---

## Adım 4 — Kanban Project board

Zaten public Kanban oluşturdun. Şu kolonları ayarla:

| Kolon | Ne zaman? |
|-------|-----------|
| **Backlog** | Henüz başlanmamış günler (D2–D20) |
| **Ready** | Bugünün issue'su, branch henüz açılmadı |
| **In Progress** | Branch'te aktif çalışıyorsun |
| **In Review** | PR açıldı, collaborator onayı bekleniyor |
| **Done** | Ümit merge etti, issue kapandı |

### Issue'ları board'a ekleme

1. **Projects** → Kanban board'unu aç
2. **Add item** → `#1`, `#2`, … veya issue başlığıyla ara
3. Tüm 20 issue'yu ekle
4. D1 → **In Review** (PR açık)
5. D2–D20 → **Backlog**

### Otomatik sync (önerilen)

Board → **⋯** → **Settings**:
- ✅ Auto-add to project: `B2B_saas_project` repo'sundaki yeni issue'lar
- Status field: Issue state + PR state ile eşle

---

## Adım 5 — Branch protection (Ümit Bey ayarlar)

**Settings** → **Branches** → **Add rule** → `main`

| Ayar | Değer |
|------|-------|
| Require pull request | ✅ |
| Required approvals | **2** |
| Dismiss stale reviews | ✅ |
| Require review from Code Owners | ✅ (opsiyonel) |
| Do not allow bypassing | ✅ |
| Restrict who can push | Sadece admin/Ümit |

> Sen merge edemezsin — bu ayar bunu garanti eder.

---

## Adım 6 — CODEOWNERS (opsiyonel)

`.github/CODEOWNERS` dosyası eklendi. Ümit Bey'in GitHub kullanıcı adını güncelle:

```
* @Faruk-T @UMIT_GITHUB_USERNAME
```

PR açıldığında otomatik review isteği gider.

---

## Günlük checklist (her gün tekrarla)

```
☐ 1. Issue'yu Kanban'da "In Progress" yap
☐ 2. main'den yeni branch aç (phase-N/section-M-...)
☐ 3. Playbook'taki TÜM görevleri bitir
☐ 4. Commit (İngilizce, Conventional Commits)
☐ 5. Branch push
☐ 6. PR aç → Closes #N → Kanban "In Review"
☐ 7. 2 collaborator approve beklenir
☐ 8. Ümit merge eder → Kanban "Done"
☐ 9. Ertesi gün: git pull origin main → yeni branch
```

---

## Şu an yapılacaklar (onay beklerken)

- [ ] `gh auth login` → `.\scripts\setup-github-project.ps1` çalıştır
- [ ] VEYA manuel: 12 label + 4 milestone + 20 issue oluştur
- [ ] 20 issue'yu Kanban board'a ekle
- [ ] D1 issue → **In Review**, PR'ı issue'ya bağla (`Closes #1`)
- [ ] Ümit'e branch protection + 2 approval kuralını ayarlamasını söyle
- [ ] Collaborator'lara PR review linkini gönder

---

## Faydalı linkler

| Kaynak | URL |
|--------|-----|
| Issues | https://github.com/Faruk-T/B2B_saas_project/issues |
| Pull Requests | https://github.com/Faruk-T/B2B_saas_project/pulls |
| Projects | https://github.com/Faruk-T/B2B_saas_project/projects |
| Milestones | https://github.com/Faruk-T/B2B_saas_project/milestones |
