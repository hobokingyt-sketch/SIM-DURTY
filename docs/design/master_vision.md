# Master Vision

**Status: Long-range design source**

This document preserves the project's broad game/UI direction. It is aspirational and does **not** imply that described systems currently exist.

Implementation truth: `docs/state.md` + code + tests.  
Accepted durable rules: `docs/design/canon.md`.  
Build order: `docs/roadmap.md`.

When older HTML/CSS implementation wording appears below, preserve its product-design intent but follow ADR 0002 for production implementation: Godot-native Control/Container/Theme architecture.

---

# GRIT CITY — CORE GAME + UI FOUNDATION PROMPT

You are helping design and develop Grit City, a desktop crime-management simulation presented through a fictional criminal operating system.

The game is not a traditional menu-driven crime game. The city itself is a live simulation, and the player manages their criminal life through an OS layered around that living city.

## CORE GAME FANTASY

The player begins small and gradually builds a criminal operation.

The game should feel like:
- strategy game
- management simulation
- street-level crime simulator
- light god-game
- occupational/progression game

The player watches opportunities, people, money, pressure, neighborhoods, crews, contacts, property, and ongoing work interact over time.

The world should feel systemic rather than scripted.

A job should affect more than its payout.

Work can change:
- money
- pressure/attention
- reputation
- crew condition
- relationships
- available opportunities
- neighborhoods
- contacts
- future risk
- inventory/property/resources

The player should feel like they are managing a living criminal ecosystem.

## CORE LOOP

Observe the city → notice useful work → inspect the opportunity → prepare/assign resources → execute through Operations → deal with consequences → adapt.

Avoid turning the game into:
- a quest list
- a static job menu
- an RPG ability bar
- a collection of disconnected minigames

Systems should feed one another.

## THE CITY

The city is the main visual stage.

Whenever possible, the player should be able to see the simulation happening through the city rather than only reading tables.

People, work, locations, neighborhood conditions, movement, pressure, and consequences should eventually connect back to the city.

The map remains visually important even while management UI is open.

## THE CRIMINAL OS

The player interacts with the game through a fictional desktop operating system.

The OS is not decoration. It is the game's primary interaction architecture.

The screen is organized around:
- a live city workspace
- persistent system rails
- widgets
- applications
- alerts
- contextual information

Do not create unrelated floating windows or conventional RPG menus.

The OS should feel coherent, authored, and designed as one product.

## WIDGET PHILOSOPHY

Widgets are visual information displays.

Their job is to let the player understand an important part of the simulation without opening the full application.

Widgets summarize.  
Apps manage.

A widget should have one clear purpose.

Examples:

Work Scan:  
“What work is worth looking at right now?”

Crew:  
“Who is available, working, or needs attention?”

Pressure:  
“How much attention am I drawing and what is causing it?”

Money:  
“What is moving in and out of my operation?”

Widgets may use substantial space when the information benefits from it.

Do not shrink everything just because it is called a widget.

Larger widgets should expose more useful information and breathing room while preserving the same fundamental purpose.

## HIGH-END WIDGET DESIGN

Treat widgets more like polished mobile applications than sci-fi HUD panels.

Visual quality should come primarily from:
- typography
- spacing
- alignment
- hierarchy
- responsive layout
- surfaces
- state
- interaction
- real data visualization
- transitions
- information density management

Avoid using decorative vector graphics as the primary design language.

Do not solve UI quality by adding:
- circles around values
- targeting reticles
- random geometric HUD marks
- fake radar displays
- decorative glows
- fake maps
- meaningless pulsing elements
- generic progress bars everywhere

Do not make “futuristic HUD” the default visual answer.

Use animation only when it communicates something.

Good motion includes:
- a new opportunity entering
- an item moving position because its priority changed
- a selected row expanding
- a value transitioning
- a status changing
- progress advancing
- information appearing/disappearing because state changed

Animation should reinforce state and continuity, not provide visual noise.

## HTML/CSS PRODUCT DESIGN

Engineer the UI using real responsive HTML/CSS layout systems.

Favor:
- CSS Grid
- Flexbox
- container queries
- responsive grid-template areas
- consistent spacing tokens
- meaningful border radii
- restrained surface elevation
- tabular numerals
- strong typography
- accessible controls
- state-driven classes
- DOM/view transitions
- transform/opacity animation when possible

Components should gracefully reorganize based on available widget space.

Do not solve narrow layouts by simply shrinking text.

> Production note: this section preserves the original prototype language. In the Godot project, these principles map to native Containers, Control scenes, Theme resources, explicit size/layout state, Tween/AnimationPlayer, and other Godot-native mechanisms per ADR 0002.

## INFORMATION ARCHITECTURE

Grit City can contain a huge amount of information.

The goal is not to remove information.

The goal is to put information at the correct depth.

Use this hierarchy:

### GLANCE

Immediate state visible through widgets and persistent OS areas.

### WORK

The application where the player actually manages that system.

### CONTEXT

Relevant detail about the currently selected object.

### DEEP DETAIL

Breakdowns, modifiers, explanations, and advanced information.

### RECORD

History, logs, past events, and reference information.

Do not display all five layers simultaneously.

Use progressive disclosure.

## PRIMARY SCREEN RULE

Every major app should preserve a clear master information hierarchy:

APP NAME  
One short plain-language explanation of what this screen does.

Then:
- current state
- important information
- available actions
- secondary detail

Do not remove the master header in an attempt to reduce clutter.

The player should always know:
- where they are
- what this area is for
- what matters now

## TEXT RULES

Use contemporary, grounded criminal language.

Avoid:
- faux noir
- cheesy gangster terminology
- cop/procedural language unless genuinely relevant
- RPG terminology
- lore paragraphs that do not change play

Text should explain things that layout, numbers, or state cannot communicate on their own.

Do not repeatedly explain information already visible through the interface.

A card should not contain a paragraph explaining what its numbers already show.

Use short human explanations.

GOOD:  
“Worth a ride if you want the take.”

BAD:  
“This opportunity is located in another district and therefore requires the player to travel before beginning the operation.”

## INFORMATION PRIORITY

Think of information in these levels:

Critical:  
Needs player attention immediately.

Active:  
Relevant to what the player is currently doing.

State:  
Useful for making a decision.

Detail:  
Useful when investigating further.

Archive:  
Historical/reference information.

Primary interfaces should mostly show Critical, Active, and State information.

Detail belongs in contextual/deeper views.

Archive belongs in records/history.

## APPS VS WIDGETS

Never duplicate entire applications inside widgets.

Example:

Work Scan widget:  
shows available work and helps the player decide what deserves attention.

Operations app:  
handles travel, setup, planning, preparation, crew assignment, execution, and the full operation lifecycle.

The widget should hand the selected opportunity into Operations rather than reproducing Operations.

## SELECTION

Selection should drive context.

When the player clicks:
- a person
- a job
- a property
- a district
- a vehicle
- a contact

the surrounding UI should react intelligently.

Prefer transforming existing content rather than spawning another arbitrary panel.

## CONTINUOUS INFORMATION DESIGN

The interface should feel alive because information continuously changes.

Examples:
- opportunities reorder because one becomes more attractive
- a crew member changes from available to working
- pressure grows
- money arrives
- a contact becomes available
- an operation changes phase

Design components so those changes are visually understandable.

The interface should not need constant popups to explain them.

## ALERTS

Important events appear as compact alerts.

Alerts should be reserved for things requiring attention.

Separate:
- Alert = player intervention may be needed.
- Update = meaningful state changed.
- Log = something happened.

Do not make every simulation event an alert.

## LEGIBILITY

Reference display is 2560×1440.

Persistent information must be comfortably readable at that resolution without zooming or leaning toward the screen.

Do not solve density using 6–8px microtext.

If content does not fit:
- prioritize
- reorganize
- progressively disclose
- increase widget size
- remove redundant wording

Do not simply shrink typography.

## VISUAL STYLE

Contemporary criminal operating system.

Dark charcoal / gunmetal foundation.  
Muted materials.  
Restrained warm accents.  
Selective informational colors.  
High readability.  
Strong spacing.  
Professional product-design quality.

Avoid:
- generic AI dashboard aesthetic
- excessive cards
- everything having borders
- neon cyberpunk
- excessive glow
- faux-holographic HUDs
- excessive gradients
- every number becoming a badge
- every system looking identical

Each system may have its own visual presentation while still belonging to the same OS.

## SYSTEM-SPECIFIC VISUALIZATION

Different information deserves different visual treatment.

Money might use:  
flow, grouping, amounts, history, composition.

Work might use:  
priority, comparison, availability, payout, distance.

Crew might use:  
identity, status, availability, current activity.

Pressure might use:  
trend, sources, district contribution, recent change.

Do not force every system into:
label + number + horizontal bar.

Use graphs and visualizations only when real underlying data supports them.

Never invent fake historical data just to make the UI look sophisticated.

## CURRENT ENGINEERING PRINCIPLE

Build the interface part-by-part.

For each widget/app:

1. Define its single purpose.
2. Establish hierarchy.
3. Build the responsive HTML shell.
4. Engineer the actual information components.
5. Add interaction/state behavior.
6. Add real visualization where useful.
7. Add restrained motion.
8. Test it inside the full 2560×1440 game.
9. Remove anything that does not improve comprehension or decision-making.

Do not start by adding effects.

> Production note: step 3 is interpreted as a responsive native-Godot shell in the production repository.

The goal is not to make the UI look busy.

The goal is to make a deep simulation feel understandable, tactile, alive, and professionally engineered.
