# Visual North Star — Charcoal Engineered OS

Status: **LOCKED visual goal**  
Accepted by project owner: 2026-09-22  
Reference concept: `sim_durty_industrial_operations_dashboard.png`  
Reference fingerprint (SHA-256): `f5de3ed8cad41ba2ab725af8fbea70569daa0f71fc49eb0776786eafb5807ad3`  
Reference size: 1672×941

This document is the durable reconstruction of the approved concept image. The
binary concept originated in the design conversation; the rules below are the
canonical implementation target and are sufficient to judge future renders.

The target is not “dark UI” in general. It is a **charcoal, materially layered,
engineered desktop operating system** with restrained warm accents.

## 1. Overall read

At first glance the UI should read as:
- one connected machine-like operating environment,
- charcoal/graphite rather than blue-black,
- matte and slightly tactile rather than perfectly flat,
- engineered rather than decorative,
- dense but calm,
- contemporary product UI rather than futuristic HUD art.

The interface should feel expensive because of material consistency, geometry,
spacing, hierarchy and state treatment, not because every surface glows or moves.

## 2. Material hierarchy

Use a small, deliberate family of charcoal values.

Initial implementation ranges, to be tuned against real captures:

| Role | Approximate starting family | Purpose |
| --- | --- | --- |
| Chassis/background | #101315–#141719 | deepest shell / negative space |
| Primary surface | #181C1F–#1D2225 | rails, app surfaces, major panels |
| Recessed well | #121618–#171B1D | inset workspace and content wells |
| Raised control | #242A2E–#2B3236 | buttons, tabs, launcher plates |
| Edge highlight | #485055 at low contrast | top/inner material edge |
| Edge midtone | #30373B | structural border layer |
| Edge shadow | #080A0B | outer/deep seam |
| Primary text | #E4E4DF–#F0EFE9 | high-value readable copy |
| Muted text | #9FA7AA–#ADB3B5 | secondary state |
| Warm accent | #C59A52–#D2AA64 | selection, important values/actions |
| Accent recess | #54452F–#655236 | selected/primary control fill |

These are families, not permission for one-off arbitrary colors.

## 3. Diffused charcoal texture

Every major charcoal surface carries a restrained diffuse texture.

The texture target:
- low contrast,
- soft low-frequency mottling plus very fine grain,
- approximately 1–3% perceived luminance variation,
- no obvious repeated tile,
- no scratches,
- no distressed/grunge storytelling,
- no concrete/stone look,
- no glossy noise,
- no texture strong enough to interfere with text.

The player should notice “material” before consciously noticing “texture”.

Use one coherent texture system with controlled variants rather than unique noisy
backgrounds per panel.

## 4. Border and frame grammar

The concept's strongest identity comes from **layered engineered frames**.

Major chassis/panels use a restrained 3-stage edge:

1. dark outer containment/shadow line,
2. graphite structural line,
3. subtle inner highlight/recess line.

Large regions may add a narrow inset well inside that frame.

Corners are **small chamfers / clipped engineering corners**, not pill-rounding.
Small controls may keep slight radius where required for legibility, but the
dominant shell language is clipped, machined and rectangular.

Borders must have hierarchy:
- shell/chassis: strongest layered frame,
- app region: strong but subordinate,
- widget: medium frame,
- control: compact raised edge,
- separators: single quiet seam.

Do not give every label or value its own border.

## 5. Depth model

Use only a few depth levels:

### Level 0 — chassis
Darkest shell and inter-panel seams.

### Level 1 — surface
Rails, app areas and workbench surfaces.

### Level 2 — recessed well
Main content wells, app interiors, list/body areas.

### Level 3 — raised control
Buttons, tabs, launcher plates, widget manipulation controls.

### Level 4 — active/selected
Same physical system plus warm accent edge/fill. Never solve selection with glow.

Depth comes from:
- border values,
- subtle inner shadow,
- restrained top-edge highlight,
- local fill shift,
- spacing.

Avoid large drop shadows that make the UI look like floating web cards.

## 6. Control language

Buttons and tabs should look purpose-built into the OS:
- dark raised plate,
- quiet top/inner highlight,
- darker lower/outer edge,
- compact chamfer/radius,
- balanced padding,
- readable text,
- consistent focus treatment.

Primary action:
- warm charcoal/brass-brown fill,
- brass edge,
- no neon glow,
- clearly stronger than ordinary buttons.

State system:
- normal: graphite raised,
- hover: slightly brighter material/edge,
- pressed: visually seated/inset,
- selected: warm accent edge and restrained warm fill,
- disabled: lower contrast without disappearing,
- keyboard focus: distinct brass outline layered over the current state.

## 7. Structural seams and engineered detail

Use small designed details sparingly:
- short seam breaks,
- tiny center ticks,
- clipped corner plates,
- subtle inset lines,
- compact hardware-like handles where interaction requires them.

These details should reinforce real boundaries or affordances. They are not
permission to add random targeting marks, pseudo-circuitry or decorative vectors.

## 8. Typography

Typography remains clean and contemporary.

Hierarchy in the concept:
- large app/task title,
- medium region title,
- small uppercase system label,
- clear body text,
- tabular or stable-width numerals where useful,
- warm accent used selectively for key values and active state.

Uppercase micro-labels should use modest tracking/spacing and remain readable.
No tiny “tech” fonts. No stencil/military type as a shortcut to atmosphere.

## 9. Iconography

Icons are:
- simple outlined symbols,
- consistent stroke weight,
- visually centered,
- mounted inside engineered launcher/control plates,
- readable before decorative.

Do not draw elaborate HUD glyphs. The icon plate and interaction state provide
most of the material character.

## 10. Spacing and density

The visual target is dense but not cramped.

Prefer:
- 20–32 units around major content groups,
- 10–16 units inside compact controls/widgets,
- strong vertical alignment,
- repeated baselines,
- generous negative space inside the center app when content is intentionally sparse.

Do not fill empty areas merely to make the UI look “finished”.

## 11. Widget treatment

Widgets should feel like instruments fitted into the workbench:
- chassis frame,
- recessed body,
- compact engineered header,
- stable manipulation controls,
- information hierarchy specific to the widget,
- no generic card-with-a-shadow aesthetic.

Semantic forms from 6B remain. Material styling must not reduce their functional
differences to differently sized copies.

## 12. App treatment

Center-focus apps use the strongest interior well and enough quiet space to make
their hierarchy obvious. Rail apps use the same material language but reflow
their navigation into narrow authored anatomy.

The shell must remain recognizably the same OS when apps change.

## 13. Motion

Material polish does not imply perpetual animation.

Allow short, functional transitions for:
- hover/press,
- selection,
- app enter/return,
- widget form/reflow,
- meaningful value change,
- attention state.

Target initial transition family: approximately 100–180 ms for controls and
150–240 ms for larger state changes, then tune by feel.

Reduced-motion mode removes travel/scale motion while preserving state clarity.

## 14. Explicit non-goals

Do not drift into:
- blue cyberpunk,
- neon glow,
- glassmorphism,
- glossy black plastic,
- brushed-metal photo textures,
- distressed post-apocalyptic scratches,
- faux-military HUD markings,
- giant soft web-card shadows,
- excessive rounded rectangles,
- borders around every value,
- fake radar/data visualizations.

## 15. Acceptance question

For every UI screenshot, ask:

> Does this look like one charcoal engineered operating environment built from a
> coherent material kit, or like ordinary Godot controls placed on dark panels?

If the second answer is plausible, the visual pass is not complete.
