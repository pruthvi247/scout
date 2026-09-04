# Org Structure & Role Hierarchy — Spec / MoM

> Minutes of discussion between the team on how the **Organization Structure Engine**
> and **Role Hierarchy** should work in Scout. This captures the agreed model for
> nodes, roles, and permission propagation. It refines Sections 1–3 of
> [01-detailed-requirement.md](01-detailed-requirement.md).

---

## 1. Onboarding & Organization Creation

- A user **registers** into the app.
- The user **creates an organization** and defines:
  - The **org structure** (node types and hierarchy)
  - The **role structure** for each node (roles and their hierarchy)
- Each node automatically has an **owner** — determined by the role hierarchy (see Section 3).

## 2. Organization Levels = "Nodes"

- The Owner **defines the org levels** and the **hierarchy** between those levels.
- Technically, each level/entity in the hierarchy is called a **Node**.
- Levels are **dynamic and user-defined** — not hardcoded (no fixed Country → State → District).
- A node has:
  - a **Node Type** (the level, e.g. State, District, Ward)
  - a **Parent Node**
  - zero or more **Child Nodes**

**Example (political party):**

```txt
National (node)
 └── State (node: Andhra Pradesh)
      └── District (node: Chittoor)
           └── Mandal (node)
                └── Ward (node)
```

## 3. Roles = User-Defined, Per Node / Per Level

- For each node, define a **role hierarchy**.
- Roles are **dynamic and user-defined**.
- Roles are **ordered** from top (highest authority) to bottom (lowest authority).
- The **top role in any node's role hierarchy is automatically that node's owner**.
- **Top role of the node should have a reporting role from one of the roles of the above node level** — this creates the governance chain across nodes.

### Node Owner is Top Role (Automatic)

When you assign roles to a node instance, the person in the **top role automatically owns that node** and all roles/levels below it.

**Reporting Chain:** The top role should report to one of the roles in the parent node's hierarchy, creating an unbroken governance chain.

**Example: Reporting Chain Across Nodes**

```
National (node)
├─ Role: President (TOP → owns National, no parent)

Andhra Pradesh (node, child of National)
├─ Role: Incharge (TOP → owns AP)
└─ Incharge reports to: National's President ← (governance link)

Chittoor (node, child of AP)
├─ Role: Captain (TOP → owns Chittoor)
└─ Captain reports to: AP's Incharge (or Admin or Secretary from AP) ← (governance link)
```

In this example:

- **Captain (Chittoor's owner)** reports to **Incharge or Admin (AP's node)**, establishing a clear chain of accountability.
- This reporting is **separate** from membership roles in Chittoor—it's purely for governance and accountability upward.
- Captain can report to any role in AP's hierarchy (Incharge, Admin, Secretary, President, Manager), depending on organizational needs. This is defined while creating node and role heirarchy

**Example 1: Andhra Pradesh (State Node)**

Role hierarchy: `Incharge` > `Admin` > `Secretary` > `President` > `Manager`

```
Incharge (TOP ROLE → automatically owns this node)
   ├─ has full control of Admin, Secretary, President, Manager roles
   └─ has full control of all child nodes (Districts below AP,1 level below or direct child nodes)

Admin
   ├─ has full control of Secretary, President, Manager roles
   └─ has full control of child nodes where he/she is the reporting head from point or reporting chain

Secretary
   ├─ has full control of President, Manager roles
   └─ has full control of child nodes where he/she is the reporting head

... (and so on)
```

**Example 2: Chittoor (District Node)**

Role hierarchy: `Captain` > `Marshall` > `Incharge` > `Supervisor` > `Manager` > `Member`

```
Captain (TOP ROLE → automatically owns this node)
   ├─ has full control of Marshall, Incharge, Supervisor, Manager, Member roles
   └─ has full control of all child nodes (Mandals below Chittoor)

Marshall
   ├─ has full control of Incharge, Supervisor, Manager, Member roles
   └─ has full control of child nodes,where he/she is the reporting head

Incharge
   ├─ has full control of Supervisor, Manager, Member roles
   └─ has full control of child nodes,where he/she is the reporting head

... (and so on)
```

### Multi-Level Example: Full Org Structure

```
National (node)
├─ Role: President (TOP → owns National)
│  └─ has control of all roles below + all child nodes
│
└─── Andhra Pradesh (node, child of National)
     ├─ Role: Incharge (TOP → owns AP)
     │  ├─ has control of Admin, Secretary, President, Manager roles in AP
     │  └─ has control of child nodes (Districts)
     │
     └─── Chittoor (node, child of AP)
          ├─ Role: Captain (TOP → owns Chittoor)
          │  ├─ has control of Marshall, Incharge, Supervisor, Manager, Member roles in Chittoor
          │  └─ has control of child nodes (Mandals)
          │
          └─── Mandal-X (node, child of Chittoor)
               ├─ Role: Ward-Incharge (TOP → owns Mandal-X)
               │  └─ has control of all roles + child nodes in Mandal-X
```

### Permission Flow Example

When a user is assigned the **Incharge role at Andhra Pradesh**:

1. They **own** the AP node.
2. They have **full control** over `Admin`, `Secretary`, `President`, `Manager` roles _within AP_.
3. They have **full control** over all child nodes (Chittoor, other districts).
4. They **cannot directly manage** roles in Chittoor — that's controlled by Chittoor's top role (Captain) or reporting head of chittoors's top role.
5. But Chittoor's Captain (as owner of Chittoor) reports to AP's Incharge or any other role from AP (State level).

### Role Sharing Across Sibling Nodes

Different nodes at the **same level** may or may not share similar role hierarchies:

- **AP (State)**: Incharge > Admin > Secretary > President > Manager
- **Telangana (State)**: Incharge > Admin > Secretary > President > Manager (same baseline)
- **Or**, Telangana can add extra roles: Incharge > Admin > Secretary > **Regional Lead** > President > Manager (extended)

Each state's **Incharge is automatically the owner of that state** and manages that state's structure independently.

## 4. Principle Propagation (the core rule)

The permission/ownership model propagates across levels as **`n+1, n, n-1`**.

- A **higher-level role** for a given node owns:
  - the **org level below** it (`n-1`), and
  - the **roles below** it.
- We only ever reason about **+1, n, and -1** relative to any role/node.

### Thumb rule

> **Any user/role has full control over the role/level immediately below them —
> and only ONE level down. No one can manage two levels below.**

- Parent node/role → **full control** over its direct child node/role.
- Control does **not** cascade two levels deep (a role at `n` cannot directly manage `n-2`).

### Illustration

```txt
        n+1   (parent role / level)   ── has full control of ──►  n
         │
         n    (current role / level)  ── has full control of ──►  n-1
         │
        n-1   (child role / level)    ── cannot be reached by ──►  n+1 directly
```

- `n+1` manages `n`.
- `n` manages `n-1`.
- `n+1` does **not** directly manage `n-1` (that's two levels down).

## 5. Two Independent Structures

The registering user (org architect) defines **two structures**, and both are user-defined and dynamic:

1. **Org structure** — the node/level hierarchy (geography or organizational tree).
   - Example: National → State → District → Mandal → Ward
2. **Role structure** — the role hierarchy attached to each node type.
   - Example at State level: Incharge > Admin > Secretary > President > Manager
   - Example at District level: Captain > Marshall > Incharge > Supervisor > Manager > Member

**Governing rules:**

- _Parent node controls child node_ (one level only).
- _Top role and his reporting head in any node's hierarchy automatically owns that node_ (emergent ownership).
- _Higher role controls lower role within the same node_ (one level only).
- Both org hierarchy and role hierarchy follow the `n+1, n, n-1` propagation principle.

---

## 6. Creating Nodes & Linking Role Hierarchies

When creating a node instance, the architect specifies:

1. **Node Type** — the level in the org hierarchy (State, District, Mandal, etc.)
2. **Parent Node** — which node this one belongs under (optional for root nodes)
3. **Role Hierarchy** — the roles for this node, ordered by authority
4. **Parent Role Link** — (for the top role only) which role in the parent node's hierarchy this node's owner reports to

**Setup Process:**

```
Step 1: Define Org Structure
  National
   └── State Type
   └── District Type
   └── Mandal Type

Step 2: Create Node Instances & Define Roles

  National (node instance)
    Roles: President > Secretary > Treasurer
    Owner: President (no parent, root node)

  Andhra Pradesh (node instance, parent: National)
    Roles: Incharge > Admin > Secretary > President > Manager
    Owner: Incharge
    Parent Role Link: Incharge reports to National's Secretary (or President, or Treasurer)

  Chittoor (node instance, parent: Andhra Pradesh)
    Roles: Captain > Marshall > Incharge > Supervisor > Manager > Member
    Owner: Captain
    Parent Role Link: Captain reports to one of AP's roles (Incharge, Admin, Secretary, President, Manager)

Step 3: Cascade Complete
  Result: National President
          └── AP Incharge (reports to National Secretary)
              └── Chittoor Captain (reports to AP Incharge)
```

**Key Point:**

The **parent role/reporting link is needed** — it ensures the node owner has a clear reporting line and receives governance from the parent node without being an orphan.

---

## Agreed Rules Summary

| #   | Rule                                                                                      |
| --- | ----------------------------------------------------------------------------------------- |
| 1   | Registering user **defines** the org structure (nodes) and role structure (roles/levels). |
| 2   | Org levels are **Nodes** — user-defined, dynamic, with parent/child links.                |
| 3   | **Each node has a top role that automatically owns that node** (ownership is emergent).   |
| 4   | Roles are ordered (ranked) within each node; sibling nodes can share similar role sets.   |
| 5   | Permission propagation is **`n+1, n, n-1`** — we only care about ±1 and n.                |
| 6   | A role/user has **full control of roles directly below** it _within the same node_.       |
| 7   | A role/user has **full control of child nodes** (one level down the org hierarchy).       |
| 8   | Control is **single-level only** — no managing two levels below.                          |
| 9   | **Parent node → child node** and **top role → lower roles** both follow the same rule.    |

## Design Decisions (Clarifications)

### Q1: Role Binding — Node Instance vs. Level-Wide Default

**Decision:** Roles are **bound to a specific node instance**, not at a level-wide (node type) default.

**Implication:**

- Incharge role at **AP node** is separate from Incharge role at **Telangana node**.
- Each node instance has its own role hierarchy, even if the structure looks similar.
- There is no "State-level role template" that all states inherit; instead, each state is configured independently.

---

### Q2: Role Propagation Across Sibling Nodes

**Decision:** Role additions **do NOT propagate** to sibling nodes at the same level.

**Implication:**

- If Telangana (State) adds "Regional Lead" to its role hierarchy, AP (another State) is **not affected**.
- Telangana's role hierarchy: Incharge > Admin > Secretary > **Regional Lead** > President > Manager
- AP's role hierarchy stays: Incharge > Admin > Secretary > President > Manager
- Each node manages its role structure independently.

---

### Q3: Cross-Node Reporting — Node Owners Link to Parent Node Roles

**Decision:** Each node's **top role (owner) link to a parent role** from the parent node's role hierarchy. Lower roles are **always node-local**.

**Mechanism:**

When defining a **child node's role hierarchy**, you can specify:

1. The **node owner** (top role) — e.g., Captain at Chittoor
2. ** parent role** — a role from the parent node's hierarchy that Captain reports to
   - E.g., Captain reports to Incharge (or Admin, or Secretary) from Andhra Pradesh

**Implication:**

- **Node owners** have a reporting relationship upward through the parent node's hierarchy.
- **Lower roles** within a node report within that same node (node-local).
- **Regular members** (non-top-role) cannot report across nodes; they only report to their node's role hierarchy.

**Example:**

```
National
├─ Node: Andhra Pradesh
│  ├─ Roles: Incharge (owner) > Admin > Secretary > President > Manager
│  └─ Incharge: reports to National's President (optional parent role)
│
└─ Andhra Pradesh
   └─ Node: Chittoor
      ├─ Roles: Captain (owner) > Marshall > Incharge > Supervisor > Manager > Member
      └─ Captain: reports to Incharge / Admin / Secretary / President / Manager from AP
         (chose one of these as their parent/head)

         When Captain (from Chittoor) reports to Incharge (from AP):
         → Captain has all access and control over Chittoor's roles and child nodes
         → Captain's decisions are aligned with AP's hierarchy
         → Members in Chittoor report to Chittoor's hierarchy, NOT to AP
```

**Key Benefits:**

- Node owners are **not orphans** — they have a clear reporting line to the parent node.
- **Flexibility** — a node owner can choose which parent role to report to.
- **Clear governance** — lower roles stay local; only top roles cross node boundaries.
- **Scalability** — child nodes inherit parent accountability without silos.

---

### Important: Node Owner & Reporting Head — Equal Powers

**Critical Point:** The **node owner** and their **reporting head from the parent node level** have **almost equal powers** over the nodes that the node owner manages.

**Relationship & Authority:**

When a node owner (e.g., Captain at Chittoor) reports to a role in the parent node (e.g., Incharge from AP):

1. **Node Owner (Captain)** has:
   - Full control over Chittoor's role hierarchy and members
   - Full control over all child nodes under Chittoor
   - Day-to-day operational authority over Chittoor

2. **Reporting Head ( from AP)** has:
   - **Same level of access and control** over Chittoor's roles and nodes (through the reporting link)
   - Authority to oversee Captain's decisions
   - Authority to manage Chittoor's operations if needed
   - Can intervene in Chittoor's hierarchy when necessary

**Purpose of This Relationship:**

- **Prevents Orphaned Nodes:** The node owner has a clear chain of command and is never independent.
- **Distributed Authority:** Both the node owner and their reporting head can manage the same nodes, ensuring no single point of failure.
- **Clear Accountability:** The reporting head provides oversight and governance.
- **Flexible Management:** Either can take action on Chittoor without requiring explicit delegation.

**Example:**

```
Andhra Pradesh (AP Node)
├─ Role: Incharge (owner, reports to National President)
│  ├─ Can manage all roles/nodes in AP
│  └─ Can manage Chittoor (where Captain reports to Incharge)
│
└─ Chittoor (District Node)
   ├─ Role: Captain (owner, reports to Incharge from AP)
   │  ├─ Can manage all roles/nodes in Chittoor
   │  └─ Full operational control
   │
   └─ Relationship: Incharge (AP) and Captain (Chittoor) both have equal power over Chittoor
      - Incharge can override, audit, or manage Chittoor's operations
      - Captain owns and operates Chittoor day-to-day
      - Both are accountable, preventing silos and orphaned nodes
```

---

## Updated Rule

| #   | Rule                                      | Clarification                                                                                  |
| --- | ----------------------------------------- | ---------------------------------------------------------------------------------------------- |
| 10  | **Roles are node-instance bound**         | Each node has its own role hierarchy; no inheritance from level-wide templates.                |
| 11  | **Role additions are local to that node** | Extending a role hierarchy in one node doesn't affect sibling nodes.                           |
| 12  | **Node owners can link to parent roles**  | Top role of a child node can report to one role in the parent node's hierarchy for governance. |
| 13  | **Lower roles are node-local**            | Non-owner roles in a node report within their own node; they do not cross node boundaries.     |
