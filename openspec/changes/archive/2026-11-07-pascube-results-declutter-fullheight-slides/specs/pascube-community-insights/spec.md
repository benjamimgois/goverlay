# Spec Delta

## MODIFIED Requirements

### Requirement: Results Carousel Navigation
The PasCube user interface SHALL present results in a six-slide carousel in the exact order: Overview, Curve, Silicon, Efficiency, Scaling, Distros, with a compact bottom-right dash/dot pagination and countdown pill indicator (`[ ━━ ▪ ▪ ▪ ▪ ▪ | Xs ]` / `PAUSED`) and pause-on-hover autoplay, without rendering a top-right navigation card.

#### Scenario: Navigating through six results slides
- **WHEN** the user views the benchmark results screen
- **THEN** the interface omits the top-right slide navigation box, renders a compact bottom-right indicator pill displaying an elongated active slide dash (`━━`), five inactive clickable slide dots (`▪`), and a live countdown (`8s`/`6s` or `PAUSED` on hover), supports smooth horizontal transitions, advances automatically when not hovered, and supports keyboard, mouse wheel, and side arrow navigation.
