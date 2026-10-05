# Game Design Document (GDD)
# 🐾 Beast Haven: Sanctuary Tycoon

> **Version** : 1.0.0-alpha  
> **Genre** : Tycoon / Simulateur Hybride & Élevage de Créatures  
> **Direction Artistique** : Stylisé / Cartoon / Low-poly féerique  
> **Cible Principale** : PC & Tablette (Interface de gestion riche, ergonomique et visuelle)  
> **Moteur** : Roblox Engine (Luau, synchronisé avec Rojo)

---

## 1. Vision & Pitch Général

**Beast Haven: Sanctuary Tycoon** réinvente le genre du Tycoon Roblox classique (souvent réduit à marcher sur des boutons passifs) en combinant :
1. **La gestion & l'automatisation en grille libre** (placement d'enclos, convoyeurs magnétiques, collecteurs d'essence, ouvriers PNJ "Wisp Keepers").
2. **Un système génétique d'hybridation innovant** (fusion d'essences de créatures pour faire éclore des espèces rarissimes avec des mutations Cosmétiques et Multiplicateurs : Shiny, Neon, Cosmique).
3. **Une dimension sociale forte par le Tourisme de Sanctuaires** (les joueurs ouvrent leur parc aux visiteurs, fixent un prix d'entrée, reçoivent des évaluations en étoiles et grimpent dans le classement mondial des Sanctuaires les plus prestigieux).

---

## 2. La Boucle de Gameplay Principale (Core Loop)

```
       [ 1. Élever & Câliner ]
            │  Les créatures produisent de l'Essence Féerique
            ▼
    [ 2. Automatiser les Flux ]
            │  Convoyeurs + Collecteurs acheminent l'Essence
            ▼
     [ 3. Hybrider & Incuber ]
            │  Fusion génétique dans l'Incubateur -> Nouvelles Espèces
            ▼
    [ 4. Débloquer de Nouveaux Biomes ]
            │  Plaines -> Crique -> Céleste (Tiers 1 à 5)
            ▼
     [ 5. Ouvrir au Tourisme Social ]
            │  Billetterie, Visites entre joueurs, Votes 5 étoiles
            ▼
  [ 6. Prestige & Réinvestissement ] ──► (Retour à l'étape 1)
```

---

## 3. Les Créatures & le Système Génétique d'Hybridation

### 3.1 Éléments & Statistiques
Chaque créature appartient à une famille élémentaire :
- **Plante (Flora)** : Lapin de Mousse, Pousse Étoilée (Production constante, facile à nourrir).
- **Eau (Aqua)** : Loutre d'Écume, Tortue Coralline (Génère des perles d'harmonie bonus).
- **Vent (Zephyr)** : Félin Éolien (Production rapide, accélère les convoyeurs proches).
- **Feu (Pyro)** : Draconet Flamboyant (Production explosive, nécessite un habitat volcanique).
- **Arcane (Mystic)** : Renard Astral, Wyrm Boréal (Production très élevée, booste le tourisme).
- **Stellaire (Astral)** : Kitsune Céleste, Titan d'Éther (Tier Mythique / Divin).

### 3.2 Formule de Production d'Essence
$$\text{Production par Impulsion} = \text{Taux Base} \times \text{Mult Rareté} \times \text{Mult Mutation} \times \text{Facteur Bonheur} \times \text{Niveau}$$

- **Raretés** :
  - *Common* ($\times 1.0$)
  - *Uncommon* ($\times 1.8$)
  - *Rare* ($\times 3.5$)
  - *Epic* ($\times 7.0$)
  - *Legendary* ($\times 15.0$)
  - *Mythic* ($\times 35.0$)
  - *Divine* ($\times 100.0$)

- **Mutations Cosmétiques & Stats** :
  - *Standard* ($\times 1.0$)
  - *Shiny* ($\times 1.5$ + reflets dorés scintillants)
  - *Neon* ($\times 2.2$ + contours néon luminescents)
  - *Cosmic* ($\times 3.5$ + traînée de nébuleuses violettes)

---

## 4. L'Automatisation du Sanctuaire

Pour éviter la monotonie des tycoons traditionnels :
1. **Convoyeurs & Répartiteurs** : Les joueurs posent physiquement des tapis roulants reliant leurs enclos au **Coffre Central**. L'essence et les œufs transitent de manière fluide et visible.
2. **Auto-Harvesters** : Des collecteurs d'arôme magique aspirent les orbes d'essence dès qu'une créature s'exprime.
3. **Wisp Keepers (PNJ Gardiens Follets)** :
   - Petits esprits lumineux logeant dans la *Cabane des Follets*.
   - Ils se déplacent automatiquement pour nourrir les créatures dont le bonheur passe sous 75%.
   - Maintiennent un bonus de production de $+50\%$.

---

## 5. Tourisme, Billetterie & Prestige Social

- **Guichet de Billetterie** : Placé à l'entrée de la parcelle. Le joueur règle son tarif d'entrée (de 0 à 50 Essence).
- **Touristes PNJ & Joueurs Réels** :
  - Les autres joueurs du serveur peuvent se téléporter à votre sanctuaire via l'annuaire des parcs.
  - Le ticket d'entrée est automatiquement reversé au propriétaire.
- **Système d'Évaluation & Tickets de Prestige** :
  - Les visiteurs peuvent laisser une note de 1 à 5 étoiles ⭐.
  - Chaque note positive confère des **Tickets de Prestige** 🎟️ servant à acheter des cosmétiques d'enclos uniques, des auras et des fontaines magiques.
  - Classement affiché au centre de la carte : *Top Sanctuaires de la Semaine*.

---

## 6. Ergonomie Spécialement Pensée pour PC

- **Placement sur Grille Libre avec Raccourcis Clavier** :
  - `[B]` : Ouvrir le catalogue de construction.
  - `[R]` : Pivoter la structure sélectionnée à 90°.
  - `[Clic Gauche]` : Valider et construire.
  - `[Clic Droit]` ou `[Esc]` : Annuler.
  - `[H]` : Ouvrir le laboratoire d'hybridation.
  - `[V]` : Ouvrir le registre de billetterie & tourisme.
  - `[Z]` : Voir l'arbre d'expansion des biomes.

---

## 7. Modèle Économique & Monétisation Éthique

1. **Pass de Saison Gratuit** (Défis d'élevage, récompenses de cosmétiques).
2. **Gamepasses Confort (Optionnels & Non-P2W)** :
   - *Double Tapis Roulant* (Accélère la vitesse de transport des convoyeurs).
   - *Super Incubateur* (+2 emplacements d'œufs simultanés).
   - *Guide Touristique VIP* (+50% de flux de touristes PNJ).
3. **Produits Développeurs** : Packs de Cristaux d'Harmonie, accélération instantanée d'éclosion d'œufs.
