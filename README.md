# Zone Farclip

**Zone Farclip** is a lightweight World of Warcraft addon designed to help **prevent crashes in crowded zones**, particularly on 32-bit executables. It allows you to set custom view distances (farclip) per zone, improving performance and visuals without sacrificing gameplay experience.

This addon is especially useful for players experiencing crashes due to memory allocation limitations in **32-bit WoW clients**.

## Why Crashes Happen:
In World of Warcraft (3.3.5a), the 32-bit executable is limited by how much memory it can allocate. Despite having large amounts of RAM on modern 64-bit systems, the 32-bit version of WoW can only access a fraction of that memory. This becomes problematic in memory-intensive areas like **Dalaran**, where the game tries to load a large number of assets and objects at once, often leading to **crashes** due to insufficient memory allocation.

**Zone Farclip** addresses this issue by dynamically reducing the view distance in crowded zones like Dalaran, which helps minimize memory usage and prevents these crashes from occurring.

## Features:
**Per-Zone Farclip Settings**
Save different view distances for each zone, allowing for optimization of performance in high-traffic areas like Dalaran while maintaining higher visual quality in less crowded regions.


**Smart Defaults**
Automatically falls back to the max farclip distance (1277) for zones that have not been configured.


**Easy UI**
Features a simple dropdown menu (continent → zone) with a slider control for adjusting the farclip distance.


**Auto-Apply**
The addon automatically applies your saved farclip settings as you enter different zones.


**Persistent Memory**
Your settings are remembered between sessions, so custom farclip distances are applied automatically without having to reconfigure each time you log in.

## How It Helps:
- **Prevents Crashes in Dalaran**:


By reducing the view distance in memory-heavy zones, the addon ensures the 32-bit executable can allocate memory more effectively and prevents crashes that are caused by insufficient memory.
- **Boosts FPS in Crowded Zones**:

By lowering the draw distance in busy areas, you can achieve better performance, especially on lower-end systems, without compromising visual fidelity in open zones.

- **Optimizes Performance**:

Customize the view distance to suit your playstyle, reducing lag or stuttering in crowded areas while still maintaining high-quality graphics in open world zones.

## Installation:
1. Download the addon file.
2. Extract it into your `World of Warcraft/Interface/AddOns` directory.
3. Log into the game and type `/zfc` to access the configuration window.

## Commands:
- `/zfc` – Toggles the configuration window.

## Compatibility:
- **WoW Version**: 3.3.5
