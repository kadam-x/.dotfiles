# Hybrid Agent Instructions: Architectural & Behavioral Constraints

## 1. Execution Philosophy & Scope Control

- **Surgical Scope:** Touch only what is required. Every changed line must trace directly to the request.
  - Do not "improve" adjacent code, comments, or formatting.
  - Do not refactor unbroken components. Match existing style exactly.
  - If unrelated dead code is identified, surface it textually; do not delete it.
- **Simplicity First:** Implement the minimum code that solves the problem.
  - No speculative features, unrequested abstractions, or predictive flexibility/configurability.
  - No error handling for impossible scenarios.
  - If a 200-line implementation can be compressed to 50 lines, rewrite it.
- **Goal-Driven Verification:** Transform tasks into verifiable goals.
  - Define concrete success criteria (e.g., "_Write test reproducing bug → implement fix → verify pass_").
  - For multi-step tasks, state an explicit plan with check-steps before execution.
  - Verification commands: `pytest` for tests, `ruff check` for lint. Run these before declaring a task complete.
- **Explicit Assumption Modeling:** Stop execution if ambiguity is encountered. State assumptions explicitly and present multiple interpretations rather than choosing silently.
- **Blast-Radius Checkpoint:** If a change touches more than 5 files, stop and confirm scope with the user before proceeding.

## 2. Git & Commit Hygiene

- Never create, checkout, or switch branches. Branch management is handled by the user.
- Never push to any remote. Pushing is handled by the user.
- Commit messages: imperative mood (e.g., "Add", "Fix", "Remove"), one logical change per commit.
- No co-author trailers, no AI-attribution footers in commit messages.
- If a task spans multiple unrelated changes, split into multiple commits rather than one large commit.

## 3. Frontend Constraints

### Visual Design & Color Theory

- **Palette Boundaries:** Inhibit generic purple gradients. Inhibit random background glowing lights. Use calm, low-saturation tones: soft gray, green, or off-white. Ensure box borders are smooth, clean, and structurally uniform.
- **Typography:** Inhibit the standard `Inter` font family. Select a unique, clean alternative font. Apply expanded letter-spacing to uppercase headers. Strict constraint: Button text must remain on a single horizontal line; prevent text-wrapping or multi-line bending.
- **Asset Selection:** Inhibit low-fidelity computer illustrations/clipart. Utilize high-quality, authentic photography. Deploy unique, non-standard icon sets. Utilize subtle, clean video or motion backgrounds for high-impact zones.
- **Layout Mechanics:** Maintain absolute vertical symmetry (top padding must equal bottom padding within containers). Avoid dense layout crowding; maximize negative space. Implement smooth, low-latency entrance transitions (`slide-in` / `fade-in`) on initial page load.

## 4. Backend Constraints (Python)

### Code Architecture & Import Order

- **Import Hierarchy:** Group and order imports strictly from top to bottom:
  1. Third-party dependencies
  2. Built-in standard library modules
  3. Local/internal project modules
- **Structural Granularity (Single Responsibility):** For files/classes above ~100 lines or handling more than one concern, enforce strict file-to-class mapping (one file, one class, summarizable in 2–3 words). Do not apply this rule to trivial/small features — do not split tiny changes into extra files purely for SRP compliance; this conflicts with Simplicity First.
- **Function Length Boundary:** Functions must fit entirely within a standard vertical screen view. If a function exceeds one screen in length, it must be refactored into a minimum of two distinct functions.

## 5. Cleanup Tracing

- **Orphan Management:** Remove imports, variables, and functions that become unused _specifically_ due to your changes.
- Do not remove pre-existing dead code unless explicitly directed by the request.
