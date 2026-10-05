# 🐾 Beast Haven: Sanctuary Tycoon

> Projet de jeu Roblox nouvelle génération : Hybride **Tycoon / Simulateur d'Élevage & Automatisation** avec système génétique d'hybridation et tourisme communautaire.

---

## 🌟 Présentation du Projet

**Beast Haven: Sanctuary Tycoon** a été conçu sur mesure à partir de tes choix :
- **Genre** : Tycoon / Simulateur Incrémental avec placement sur grille libre et automatisation.
- **Direction Artistique** : Stylisé, cartoon, low-poly et féerique.
- **Le Twist Unique** : Élevage, croisement génétique et hybridation de créatures magiques alimentant une usine de sanctuaires.
- **Automatisation** : Convoyeurs acheminant l'essence et les œufs rares, incubateurs automatiques et petits ouvriers PNJ mignons (*Wisp Keepers*).
- **Dimension Sociale** : Tourisme de parcs, billetterie personnalisable, visites entre joueurs et notation 5 étoiles avec tickets de prestige.
- **Contrôles & Ergonomie** : Interface enrichie optimisée PC (dashboards, catalogue, raccourcis clavier rapides).

---

## 📁 Architecture du Code (Rojo / Luau)

```
robloxproject/
├── default.project.json                    # Configuration Rojo pour Roblox Studio
├── docs/
│   └── GDD_BEAST_HAVEN.md                 # Document de Game Design complet (GDD)
├── src/
│   ├── ReplicatedStorage/
│   │   └── Common/
│   │       ├── Config/
│   │       │   ├── GameConfig.luau         # Paramètres généraux, grille, ticks
│   │       │   ├── RaritiesData.luau       # Tiers de raretés, multiplicateurs, mutations
│   │       │   ├── CreaturesData.luau      # Espèces, éléments, matrice d'hybridation
│   │       │   ├── BuildingsData.luau      # Enclos, convoyeurs, incubateurs, guichet
│   │       │   └── ZonesData.luau          # Biomes progressifs à débloquer
│   │       ├── Network/
│   │       │   └── NetworkUtil.luau        # Registre et gestionnaire de RemoteEvents
│   │       └── Utils/
│   │           ├── Signal.luau             # Événements légers et rapides
│   │           ├── FormatUtil.luau         # Formatage des nombres (1.5K, 2M) et durées
│   │           └── MathUtil.luau           # Snapping grille, détection de collisions AABB
│   ├── ServerScriptService/
│   │   └── Server/
│   │       ├── init.server.luau            # Point d'entrée serveur
│   │       └── Services/
│   │           ├── DataService.luau        # Sauvegarde DataStore & profils joueurs
│   │           ├── EconomyService.luau     # Gestion sécurisée des devises (Essence, Cristaux, Tickets)
│   │           ├── TycoonService.luau      # Attribution de parcelle, placement sur grille 3D
│   │           ├── CreatureService.luau    # Cycle de vie, bonheur, récolte, hybridation & mutations
│   │           ├── AutomationService.luau  # Gestion des convoyeurs et IA des PNJ Follets
│   │           └── TourismService.luau     # Billetterie, touristes PNJ et évaluations
│   └── StarterPlayer/
│       └── StarterPlayerScripts/
│           └── Client/
│               ├── init.client.luau        # Point d'entrée client
│               └── Controllers/
│                   ├── PlotController.luau     # Prévisualisation holographique, rotation [R], placement
│                   ├── CreatureController.luau # Effets visuels, popups de récolte flottants
│                   └── UIController.luau       # Interface PC (Barre de devises, Hotbar, Modales)
```

---

## 🎮 Raccourcis Clavier en Jeu (PC)

| Touche | Action |
|---|---|
| **B** | Ouvrir / Fermer le **Catalogue de Construction** (Enclos, Convoyeurs, Incubateurs) |
| **H** | Ouvrir le **Laboratoire d'Hybridation & Génétique** |
| **V** | Ouvrir le menu **Tourisme & Billetterie** (Prix des billets, Avis des visiteurs) |
| **R** | **Pivoter** la structure de 90° en mode prévisualisation |
| **Clic Gauche** | Confirmer le placement sur la grille du sanctuaire |
| **Clic Droit / Échap** | Annuler le mode placement en cours |

---

## 🚀 Comment lancer et synchroniser avec Roblox Studio

1. **Installer Rojo** (si ce n'est pas déjà fait) :
   - Télécharge l'extension Rojo pour VS Code ou le binaire CLI depuis [rojo.space](https://rojo.space/).
2. **Lancer le serveur de synchronisation Rojo** dans ce dossier :
   ```bash
   rojo serve
   ```
3. **Dans Roblox Studio** :
   - Ouvre un nouveau projet vierge (*Baseplate*).
   - Ouvre le plugin **Rojo** dans Roblox Studio et clique sur **Connect** (port par défaut `34872`).
   - Tous les scripts, configurations et l'arborescence se synchronisent automatiquement en temps réel !
