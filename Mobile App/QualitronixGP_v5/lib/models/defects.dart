class Defect {
  final String name;
  final String description;
  final List<String> challenges;
  final List<String> impacts;
  final String image; // Image asset or network URL

  Defect({
    required this.name,
    required this.description,
    required this.challenges,
    required this.impacts,
    required this.image,
  });
}


List<Defect> defects = [
  Defect(
    name: "Missing Hole",
    description: "A hole absent in the PCB, affecting component placement and electrical continuity.",
    challenges: [
      "High density of modern PCBs makes detection difficult.",
      "Lighting and contrast issues obscure visibility.",
      "Small holes are hard to distinguish in packed boards."
    ],
    impacts: [
      "Hinders component insertion.",
      "Breaks electrical connections.",
      "Leads to defective circuits or complete failures."
    ],
    image: "assets/images/mising_holl.png",
  ),
  Defect(
    name: "Mouse Bite",
    description: "Small, irregular nicks along PCB edges due to incomplete etching or milling issues.",
    challenges: [
      "Subtle defects are hard to distinguish from acceptable edges.",
      "Complex PCB shapes make detection harder.",
      "Lighting and reflections obscure visibility.",
      "Automated detection struggles with minor edge variations."
    ],
    impacts: [
      "Can cause electrical issues if it reaches conductive areas.",
      "Weakens structural integrity of the PCB."
    ],
    image: "assets/images/mouse bite.png",
  ),
  Defect(
    name: "Spur",
    description: "Thin copper protrusions forming along traces, leading to potential short circuits.",
    challenges: [
      "Small size makes detection difficult.",
      "Complex designs make distinguishing defects harder.",
      "Automated inspection may misclassify spurs as normal traces."
    ],
    impacts: [
      "Leads to unintended connections and short circuits.",
      "Compromises signal transmission integrity.",
      "Reduces manufacturing yield."
    ],
    image: "assets/images/spur.png",
  ),
  Defect(
    name: "Spurious Copper",
    description: "Unintended copper remnants left after etching, causing possible short circuits.",
    challenges: [
      "Difficult to differentiate from intended traces in dense designs.",
      "Small size makes detection challenging.",
      "Lighting and material variations obscure visibility."
    ],
    impacts: [
      "Can create unintended electrical connections.",
      "Causes signal integrity issues.",
      "Reduces PCB reliability and increases manufacturing costs."
    ],
    image: "assets/images/spurious copper.png",
  ),
  Defect(
    name: "Pin Hole",
    description: "Microscopic holes in copper plating that can compromise PCB reliability.",
    challenges: [
      "Extremely small size makes detection difficult.",
      "Requires high-resolution imaging.",
      "Hard to differentiate from normal surface imperfections."
    ],
    impacts: [
      "Weakens electrical pathways.",
      "Reduces long-term PCB reliability."
    ],
    image: "assets/images/pin hole.png",
  ),
  Defect(
    name: "Short Circuit",
    description: "Unintended connections between conductive paths leading to electrical failure.",
    challenges: [
      "Can be caused by design flaws, manufacturing errors, or contamination.",
      "Difficult to detect in automated inspections.",
      "Overlapping traces and misplaced vias increase occurrence."
    ],
    impacts: [
      "Can damage components due to excessive heat or voltage spikes.",
      "Leads to malfunction or complete failure of the PCB.",
      "Increases manufacturing costs due to rework and yield loss."
    ],
    image: "assets/images/short.png",
  ),

  Defect(
    name: "Open Solder Joint",
    description: "A connection that has not been properly soldered, leading to intermittent faults.",
    challenges: [
      "Poor wetting of solder.",
      "Component placement issues.",
      "Temperature fluctuation during reflow."
    ],
    impacts: [
      "Causes unreliable electrical connections.",
      "May lead to complete failure under mechanical stress.",
      "Difficult to detect during visual inspections."
    ],
    image: "assets/images/open circuit.png",
  ),


];
