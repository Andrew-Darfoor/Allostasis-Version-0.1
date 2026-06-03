# Allostasis

Allostasis is a 2D action-adventure platformer built in Godot 4, set inside a stylized interpretation of the human body. The game focuses on exploration, combat, and environmental storytelling within a single interconnected level.

---

## 🎮 Gameplay Overview

Players explore a large interconnected world filled with enemies, locked areas, interactive objects, and environmental storytelling elements. Progression is based on exploration and weapon usage rather than linear level progression.

---

## ⚔️ Combat System

The game features three distinct weapon types:

- Sword (melee combat)
- Gun (ranged combat)
- Bomb Launcher (explosive weapon with ammo system)

Each weapon includes custom player animations while equipped, adding visual feedback and immersion during combat.

---

## 👾 Enemies

Enemy behavior is more advanced compared to earlier projects:

- Slime enemies: jump toward the player in arcing movement patterns with proper animation timing
- Virus enemies: float randomly before bursting/pushing in a direction unpredictably

---

## 🧠 Level Design

- Single interconnected level world
- Certain areas are locked and require specific weapons to access
- Interactive environmental objects such as statues provide dialogue and educational-style text about the human body
- Exploration is a key design focus

---

## 🎨 Art & Visual Design

All visual assets were custom-made using **Aseprite**, including:
- Player sprites
- Enemy sprites
- Environmental tiles
- UI elements

The game features:
- Animated player weapon states
- Dynamic UI elements
- Interactive menus with hover effects and color changes

---

## 🎬 Additional Features

- Intro cutscene (simple scripted sequence)
- Main menu with interactive start screen
- Instructions menu accessible from main menu
- Background music and weapon sound effects
- Dialogue system integrated into environmental statues

---

## 🧩 Game Development Concepts Used

### Godot Engine Concepts:
- **Nodes:** Fundamental building blocks of the game (sprites, hitboxes, audio, etc.)
- **Scenes:** Reusable collections of nodes (player, enemies, levels, weapons)
- **Signals:** Event-driven communication between objects  
  Example: `animation_finished.connect()` or `body_entered.connect()`
- **CharacterBody2D:** Core physics-based character system used for movement and collision

---

## 🛠️ Tech Stack

- Engine: Godot 4 (open-source game engine)
- Language: GDScript
- Art: Aseprite (custom pixel art creation)
- Audio: External free sound libraries + custom integration
- UI Tools: FlamingText (logos and text assets)

---

## 🌍 Theme

The game is centered around exploration inside the human body, blending gameplay mechanics with biological-themed storytelling. Environmental objects provide informational text that adds educational context to the world.

---

## 🚀 Status

Completed prototype, uploaded to itch.io.
