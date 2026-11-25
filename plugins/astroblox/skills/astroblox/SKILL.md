---
name: astroblox
description: Cria VFX, modelos 3D (Tripo AI), interfaces (GUI) e animações R15 para Roblox com a conta AstroBlox e instala no Roblox Studio. Use when the user asks for a Roblox VFX, aura, particle effect, 3D model or asset, a GUI/interface/HUD/menu/shop screen, a character animation or emote, an AstroBlox preset or an AstroBlox job ID.
---

# AstroBlox

AstroBlox makes four things for Roblox games: **VFX** (auras, hits, particles), **3D models** (a 2D reference rebuilt in 3D by Tripo AI as a textured GLB), **interfaces (GUI)** with animations, and **R15 animations** from a text description.

Reply in the user's language (default: Brazilian Portuguese). Keep messages short and show links as clickable Markdown.

## 1. Connect the account

1. Call `astroblox_account`.
2. If `connected` is false, call `astroblox_login`. Show the `url` as a link and the `code` in bold, and ask the user to open it, sign in and approve. Then call `astroblox_account` again until it reports `connected: true` (the code lasts 10 minutes; call `astroblox_login` again if it expired).
3. Never ask the user to paste a password or API key in the chat.
4. If there are no credits, no `trial` and no `freeVfx`, call `astroblox_plans`, summarize the plans in one line each and give the `subscribe` link. Presets from the catalog are free and work without a plan.

## 2. How credits work

Credits are charged per resource actually produced: **AI plan (LLM)**, **images** and **3D models (Tripo AI)**. Failed parts are refunded.

**Write the plan yourself whenever you can.** Call `astroblox_plan_guide` with the kind (`vfx`, `gui`, `model` or `anim`), follow its instructions and JSON Schema exactly, and pass the JSON object as `plan` in `astroblox_create`. The AI plan is then free; an animation planned by you costs nothing. Use the user's game context (place name, existing UI, art style) when writing it. If the server rejects the plan, it lists the fields to fix: correct them and call `astroblox_create` again.

## 3. Pick the path

- **Free preset.** For "uma aura vermelha", "aura de linhas azul" or a named reference, call `astroblox_create` with the request (or search `astroblox_aura_catalog` and pass the exact `preset` ID). A `preset_ready` answer gives `templateFile`, `propertiesFile`, `installerFile` and `options`. No credits are used.
  - If the user only gives a color and the style is open, ask: **"Você quer uma aura de linhas, de energia, de ki ou de outro estilo?"** and wait.
- **Original VFX.** `kind: "vfx"` with `auraMode: "generate"` (or your own `plan`).
- **3D model.** `kind: "model"`: AstroBlox draws a clean 2D studio reference, then Tripo AI rebuilds it as a textured GLB. Pass `quality: "game"` (light, low poly, default) or `"hd"` (more detail, PBR). If the user has a concept image, pass its local path in `referenceImage`: Tripo uses it directly and no image is charged. For a hand-built asset in Blender use `kind: "3d"` (build sheet with meshes, textures and sounds that you assemble).
- **Interface (GUI).** `kind: "gui"` with `gameStyle` (cartoon, anime, horror, fantasy, scifi, modern, retro, sport) and `audience` (kids, teen, adult). Infer both from the place: the game's name, existing UI fonts and colors in StarterGui and the map theme. Every interface comes with fonts that fit the game, a generated grayscale background tile the game tints and keeps moving, and entrance, idle, hover and press animations run by the `AstroBloxUIAnimator` LocalScript.
- **R15 animation.** `kind: "anim"` with `duration` and `loop`. Write the keyframes yourself with `astroblox_plan_guide` (`anim`) whenever possible: it is free and you can match the game's rig and timing.
- **Existing job.** Call `astroblox_job` with the ID from the site or a previous chat.

Show the `breakdown` and `maximumCredits` and whether `usesFreeVfx` is true. If `enough` is false, show the `topUp` link and stop. Only after the user accepts, call `astroblox_confirm` with the same `quote` ID and keep the returned job ID.

Poll `astroblox_job` about every 20 seconds while it is `queued` or `running`, telling the user the `stage` (plan, reference, mesh, images, package). When it is `done`, call it again with `download: true`; the files land in a local folder (`folder`). Share the `preview` link: the studio shows the 3D model and plays the animation on an R15 avatar. If it `failed`, the credits were returned: say so and offer to retry with a clearer prompt.

## 4. Install in Roblox Studio

Installation uses the Roblox Studio MCP server. If its tools are missing, tell the user to open Studio and enable **Assistant → Manage MCP Servers → Enable Studio as MCP server**, then continue with the local files.

- **Preset rig.** Read `templateFile` as bytes and base64-encode it locally. In Edit mode, run the contents of `installerFile` as a function with `(encodedBytes, presetId, options)`. It returns an unparented, editable rig. Parent it where the user wants (default `ReplicatedStorage.AstroBlox.Auras`), mount it on the character's matching body parts and keep the authored settings unless the user asked for changes. Pass `options.tintHex`, `rateMultiplier` or `brightnessMultiplier` for recolors.
- **VFX job.** Upload each PNG with the Studio upload tool to get its asset ID, fill `textureIds` in the generated installer, run it in Edit and check that every texture loads in Play. For new emitters follow [reference-emitter.luau](reference-emitter.luau).
- **Interface job.** Upload every PNG to get its asset ID, fill `textureIds` in `Instalar.luau` and run it in Edit. It creates the ScreenGui in StarterGui with the background, the animator script and every element. Wire the behaviors listed in `interactions` (buttons carry an `AstroBloxRole` attribute). Open and close panels by toggling `Visible`; the entrance replays by itself. If the place sets `Players.CharacterAutoLoads = false`, clone the ScreenGui into each PlayerGui from a script. In Play, check the entrance, the moving background, hover and click feedback on PC and on a phone-sized viewport.
- **3D model job.** Import `modelo.glb`: upload it with the Roblox Studio MCP (see its `rbx-import-asset` skill: Open Cloud model upload, then insert the asset) or ask the user to use Home → Import 3D. Scale it to `sizeStuds` from `Modelo.json`, anchor scenery, put tools inside a Tool with a `Handle`, and keep the embedded texture.
- **Animation job.** Run `Instalar.luau` in Edit: it builds the KeyframeSequence in `ServerStorage.AstroBlox.Animacoes` (and stores a temporary preview id in the `AstroBloxPreviewId` attribute). For Play and the live game the animation must be published: ask the user to right-click the KeyframeSequence → Save to Roblox (or publish from the Animation Editor), then put the ID in `Uso.luau` (a LocalScript for StarterCharacterScripts; one-shots play on E / ButtonX, loops start right away). Markers (`Hit`, `Footstep`…) fire `GetMarkerReachedSignal`.
- **3D kit job.** Follow `Montagem.json`: import the GLBs (Blender or the Studio 3D Importer), apply the supplied textures, set pivots, add the WAV cues at the listed beats and mount the result.

Keep server triggers authoritative and visual playback on the client. Clean up tracks, sounds and connections on unequip, death and respawn. Never overwrite existing scene objects without asking.

## 5. Check before saying it is done

1. Start Play and look at the result from the front and from a three-quarter view, while idle and while moving.
2. Confirm textures loaded, the scale matches the character, the face stays readable and nothing is left behind after respawn.
3. Report what was installed (instance paths), how to trigger it, the credits spent (`astroblox_account`) and anything still pending (for example, publishing an animation).

## Errors

- "não está conectado" or "revogada": run `astroblox_login` again.
- "Saldo insuficiente": share the subscribe or top-up link from the message and stop.
- "O plano não segue o schema": fix the listed fields and quote again.
- Catalog empty or preset missing: offer an original generation instead.
