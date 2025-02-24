# Docs

## Import API spec

The import should be a list of items, where each item is separated by `---`. The import should be valid `yaml`.

### Type

The item type. Can only be `RAID_ASSIGNMENTS`.

### Encounter

The encounter ID.

See https://wowpedia.fandom.com/wiki/DungeonEncounterID.

### Triggers

Assignment triggers. Can be of types `UNIT_HEALTH`, `SPELL_CAST`, `SPELL_AURA`, `RAID_BOSS_EMOTE`, `ENCOUNTER_START` or `FOJJI_NUMEN_TIMER`.

#### UNIT_HEALTH

Required values: `unit` and one of `lt`, `gt`, `pct_lt` or `pct_gt`.

Context variables: `unit_name`, `health` and `health_pct`.

```yaml
triggers:
- type: UNIT_HEALTH
  unit: boss1
  pct_lt: 20
```

#### SPELL_AURA

Required values: `spell_id`.

Optional values: `source`, `target`

Context variables: `spell_name`, `source_name` and `dest_name`.

```yaml
triggers:
- type: SPELL_AURA
  spell_id: 12345
```

#### SPELL_AURA_REMOVED

Required values: `spell_id`.

Optional values: `source`, `target`

Context variables: `spell_name`, `source_name`.

```yaml
triggers:
- type: SPELL_AURA_REMOVED
  spell_id: 12345
```

#### SPELL_CAST

Required values: `spell_id`.

Optional values: `source`, `target`

Context variables: `spell_name`, `source_name` and `dest_name`.

```yaml
triggers:
- type: SPELL_CAST
  spell_id: 12345
```

```yaml
triggers:
- type: SPELL_CAST
  spell_id: 12345
  source: boss1
```

```yaml
triggers:
- type: SPELL_CAST
  spell_id: 12345
  target: boss1
```

#### RAID_BOSS_EMOTE

Required values: `text`.

```yaml
triggers:
- type: RAID_BOSS_EMOTE
  text: "The air crackles with energy!"
```

#### ENCOUNTER_START

```yaml
triggers:
- type: ENCOUNTER_START
```

#### FOJJI_NUMEN_TIMER

Triggers when a fojji numen timer reaches 5 seconds left. This trigger requires the raid leader to have the Helper Weakaura installed. This Weakaura can be installed from within the Addon settings.

Required values: `key`.

```yaml
triggers:
- type: FOJJI_NUMEN_TIMER
  key: HALFUS_PROTOBREATH
```

### Untriggers

Same as triggers. This field is optional and really only useful if you created triggers with a delay, and you want to cancel those triggers.

### Countdown, Delay and Throttle

Most triggers support `countdown`, `delay` and `throttle`. The `countdown` value controls the countdown timer in the raid assignments popup. `delay` controls how long a raid notifications will be delayed for after triggering. `throttle` controls how many times a trigger can trigger within a set timespan.

Both countdown and delay serve a similar purpose and it's mostly a matter of if you want to show the window with a countdown timer or just delay it. Countdown makes sense for small values while delay makes sense for longer timer periods. They can also be combined.

```yaml
triggers:
- type: SPELL_CAST
  spell_id: 12345
  delay: 3
  countdown: 2
  throttle: 5
```

### Conditions

All triggers support `conditions`. Conditions is a list of things that need to be true for the trigger to go off.

#### UNIT_HEALTH

Trigger if the health of the boss is below or above a certain value.

Required values: `unit` and one of `lt`, `gt`, `pct_lt` or `pct_gt`.

```yaml
triggers:
- type: SPELL_CAST
  spell_id: 12345
  conditions: [{ type: UNIT_HEALTH, unit: boss1, pct_lt: 20 }]
```

#### SPELL_CAST_COUNT

Trigger if a spell has been cast a certain amount of time.

Required values: `spell_id` and one or both of `lt`, `gt` or `eq`.

```yaml
triggers:
- type: SPELL_CAST
  spell_id: 12345
  conditions: [{ type: SPELL_CAST_COUNT, spell_id: 54321, eq: 2 }]
```

### Metadata

Raid assignment metadata. `title` is required and is the text that will be shown in the overview and notifications.

If `notification` is set, then that is what will be shown when in notifications when a trigger goes off. The `notification` field supports string interpolation with data from the triggered event.

See specific triggers for into on context variables that are available. The format for interpolation is `%(variable)s` where the trailing `s` stands for string. Other formatting types are available. E.g `%(variable)1.2f`.

```yaml
triggers:
- type: SPELL_CAST
  spell_id: 12345
  metatada: { name: 'Finger of Doom', notification: 'Finger of Doom on %(dest_name)s!' }
```

### Assignments

The list of assignments for this trigger. Can only be of type `SPELL`.

Assignments is priority list and not a sequence. This means that the addon will always suggest the top assignment value in the list where all spells are ready.

### Example Import

```yaml
type: RAID_ASSIGNMENTS
version: 1
encounter: 1029
triggers: 
- { type: UNIT_HEALTH, unit: boss1, pct_lt: 20 }
- { type: UNIT_HEALTH, unit: boss1, pct_lt: 20, delay: 10 }
metadata: { name: 'Phase 2' }
assignments:
- [{ type: SPELL, player: Aeolyne, spell_id: 740 }, { type: SPELL, player: Dableach, spell_id: 51052 }]
- [{ type: SPELL, player: Elí, spell_id: 31821 }, { type: SPELL, player: Kondec, spell_id: 62618 }]
---
type: RAID_ASSIGNMENTS
version: 1
encounter: 1025
triggers:
- { type: RAID_BOSS_EMOTE, text: "red|r vial into the cauldron!", delay: 19, countdown: 3 }
- { type: SPELL_CAST, spell_id: 77679, delay: 7, countdown: 3 }
untriggers:
- { type: SPELL_CAST, spell_id: 77991 }
- { type: RAID_BOSS_EMOTE, text: "blue|r vial into the cauldron!" }
- { type: RAID_BOSS_EMOTE, text: "green|r vial into the cauldron!" }
- { type: RAID_BOSS_EMOTE, text: "dark|r vial into the cauldron!" }
metadata: { name: 'Scorching Blast' }
assignments:
- [{ type: SPELL, player: Aeolyne, spell_id: 740 }, { type: SPELL, player: Dableach, spell_id: 51052 }]
- [{ type: SPELL, player: Crawlern, spell_id: 740 }, { type: SPELL, player: Dableach, spell_id: 51052 }]
---
type: RAID_ASSIGNMENTS
version: 1
encounter: 1023
triggers: [{ type: SPELL_CAST, spell_id: 82848, conditions: [{ type: UNIT_HEALTH, unit: boss1, pct_lt: 25 }]}]
metadata: { name: 'Heal to full for P2!' }
assignments:
- [{ type: SPELL, player: Sîf, spell_id: 97462 }, { type: SPELL, player: Dableach, spell_id: 51052 }]
- [{ type: SPELL, player: Aeolyne, spell_id: 740 }, { type: SPELL, player: Solfernus, spell_id: 51052 }]
---
type: RAID_ASSIGNMENTS
version: 1
encounter: 1026
triggers: [{ type: RAID_BOSS_EMOTE, text: 'The air crackles with electricity!', countdown: 5 }]
metadata: { name: 'Electrocute/Crackle' }
assignments:
- [{ type: SPELL, player: Sîf, spell_id: 97462 }, { type: SPELL, player: Dableach, spell_id: 51052 }]
- [{ type: SPELL, player: Aeolyne, spell_id: 740 }, { type: SPELL, player: Solfernus, spell_id: 51052 }]
```
