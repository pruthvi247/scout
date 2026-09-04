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
- The **registering user is automatically the root node's owner** (see §9.8).

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

When you assign roles to a node instance, the person in the **top role automatically owns that node** — meaning **all roles within the node** (via node ownership; non-owner roles are single-level — see §7.1) plus its **direct child nodes only** (Node vertical, single-level). This does **not** grant control over anything two or more node-levels below.

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
   ├─ has full control of Admin, Secretary, President, Manager roles (all roles within AP)
   └─ has full control of its direct child nodes only (Districts directly below AP — one level, per §7.1)

Admin (non-owner)
   ├─ has full control of Secretary role only (the role directly below — one level, §7.1)
   └─ has full control of child nodes where he/she is the reporting head from point or reporting chain

Secretary (non-owner)
   ├─ has full control of President role only (the role directly below — one level, §7.1)
   └─ has full control of child nodes where he/she is the reporting head

... (and so on)
```

**Example 2: Chittoor (District Node)**

Role hierarchy: `Captain` > `Marshall` > `Incharge` > `Supervisor` > `Manager` > `Member`

```
Captain (TOP ROLE → automatically owns this node)
   ├─ has full control of Marshall, Incharge, Supervisor, Manager, Member roles (all roles within Chittoor)
   └─ has full control of its direct child nodes only (Mandals directly below Chittoor — one level, per §7.1)

Marshall (non-owner)
   ├─ has full control of Incharge role only (the role directly below — one level, §7.1)
   └─ has full control of child nodes,where he/she is the reporting head

Incharge (non-owner)
   ├─ has full control of Supervisor role only (the role directly below — one level, §7.1)
   └─ has full control of child nodes,where he/she is the reporting head

... (and so on)
```

### Multi-Level Example: Full Org Structure

```
National (node)
├─ Role: President (TOP → owns National)
│  └─ has control of all roles below (within National) + its direct child nodes only (States)
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
3. They have **full control** over their **direct** child nodes (Chittoor, other districts) — one level only.
4. Chittoor's **roles** are governed by Chittoor's **owner (Captain)** together with Chittoor's **reporting head** — the specific AP role that Captain is hard-linked to (see §7.3). If that reporting head is AP's Incharge, then this same Incharge governs Chittoor's roles too; any **other** AP role (not Chittoor's reporting head) cannot.
5. Chittoor's Captain (as owner of Chittoor) reports to AP's Incharge — or whichever AP role is chosen as the reporting head (State level).

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
- **Owner exception (role vertical):** a node's **owner/top role** governs the **whole node** (all roles) via node ownership; the single-level limit above applies to **non-owner** roles (see §7.1, Option B).

### Illustration

```txt
        n+1   (parent/reporting role / level)   ── has full control of ──►  n
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
2. **Role structure** — the role hierarchy attached to each node instance.
   - Example at State level: Incharge > Admin > Secretary > President > Manager
   - Example at District level: Captain > Marshall > Incharge > Supervisor > Manager > Member

**Governing rules:**

- _Parent node controls child node_ (one level only).
- _Top role and his reporting head in any node's hierarchy automatically owns that node_ (emergent ownership).
- _Higher role controls lower role within the same node_ (one level only for **non-owner** roles; the **owner/top role** governs all roles in the node via node ownership).
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

| #   | Rule                                                                                                                                                                           |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | Registering user **defines** the org structure (nodes) and role structure (roles/levels).                                                                                      |
| 2   | Org levels are **Nodes** — user-defined, dynamic, with parent/child links.                                                                                                     |
| 3   | **Each node has a top role that automatically owns that node** (ownership is emergent).                                                                                        |
| 4   | Roles are ordered (ranked) within each node; sibling nodes can share similar role sets.                                                                                        |
| 5   | Permission propagation is **`n+1, n, n-1`** — we only care about ±1 and n.                                                                                                     |
| 6   | **Non-owner** role controls only the role **directly below** it (single-level); the **owner/top role** governs all roles in the node (node ownership).                         |
| 7   | A role/user has **full control of child nodes** (one level down the org hierarchy).                                                                                            |
| 8   | Control is **single-level** across nodes (always) and for non-owner roles within a node; the owner governs its whole node.                                                     |
| 9   | **Parent node → child node** is single-level; **owner/top role → all roles in its node** (node ownership); **non-owner higher role → the role directly below** (single-level). |

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

**Decision:** Each node's **top role (owner) links to a parent role** (the **reporting head**) from the parent node's role hierarchy. This link is **mandatory for every non-root node** and **absent for the root** (no parent) — see §7.9 and §8.1. Lower roles are **always node-local**.

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
│  └─ Incharge: reports to National's President (mandatory parent-role link for non-root nodes)
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

**Critical Point:** The **node owner** and their **reporting head from the parent node level** have **equal powers over that node itself** — the reporting head is a **hard link / full co-owner** (see §7.4). This authority is **bounded to the node**; it does **not** extend to that node's own child nodes (which would be n-2).

**Relationship & Authority:**

When a node owner (e.g., Captain at Chittoor) reports to a role in the parent node (e.g., Incharge from AP):

1. **Node Owner (Captain)** has:
   - Full control over Chittoor's role hierarchy and members
   - Full control over Chittoor's **direct** child nodes (Mandals) — one level, per §7.1
   - Day-to-day operational authority over Chittoor

2. **Reporting Head (from AP)** has:
   - **Same level of access and control over the Chittoor node itself** — its roles and the node — through the hard-link
   - Per §7.4 this co-ownership is **bounded to Chittoor**; it does **not** reach Chittoor's child nodes (Mandals are n-2 and remain governed by their own owner + reporting head)
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

---

## 7. Clarifications & Design Decisions (Consolidated)

> This section consolidates the architectural review outcomes. It resolves the
> apparent contradictions in the earlier sections and is the **authoritative
> reference** where any earlier wording seems ambiguous.

### 7.1 Two Independent Verticals (the key to reading this spec)

Every apparent "contradiction" between _"controls all roles below"_ and _"only one
level below"_ disappears once you separate the **two orthogonal verticals**:

| Vertical                   | Shape                                        | Control rule                                                                                                                                                                                |
| -------------------------- | -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Node** (org tree)        | across nodes (Nation → State → District → …) | **Strictly single-level** — a node reaches only its **direct** child.                                                                                                                       |
| **Role** (within one node) | inside a single node                         | **Owner = whole node; others single-level** — the owner/top role governs **all** roles in the node (node ownership); every **non-owner** role controls only the role **directly below** it. |

- "Incharge (owner) controls Admin, Secretary, President, Manager" → this is
  **node ownership** (the owner governs the whole node). A **non-owner** role
  (e.g., Admin) controls only the role **directly below** it (Secretary) —
  single-level.
- "One level only / no managing two levels below" → this is the **Node vertical**
  (across nodes) and the **non-owner Role vertical** (within a node).

**Consequence:** _Can National's President act on Chittoor (n-2)?_ → **No.** The
node vertical is single-level; Districts are governed by their own owner +
reporting head, never by the grandparent.

### 7.2 Anchored `n+1 / n / n-1` Convention (no more direction confusion)

Fix the notation once and never deviate:

> **`n` = the node in question. `n+1` = its parent (above). `n-1` = its direct child (below).**
> "Below" always means **smaller index = child**.

**Example (relative to State = `n`):**

```txt
Nation      = n+1   (parent / above)
State       = n     (the node in question)
District    = n-1   (direct child / below)
Mandal      = n-2   (NOT directly reachable from State)
```

### 7.3 Node Governance = Exactly Two Seats/Roles (owner + reporting head)

Authority over **any** node is held by exactly two governing **seats/roles**
(owner + reporting head) — **each of which may be held by multiple people**
(§9.1, §9.6) — and both act **single-level, downward only**:

1. **Owner** — the top role, lives **inside** the node.
2. **Reporting head** — a role that lives **inside the parent node**, hard-linked to
   the owner.

Both have **full authority over that one node** (its roles and the node itself).
Neither reaches two levels down. This is what prevents orphaned nodes: even if the
owner seat is empty, the reporting head still governs the node.

> **Rewrite of the misleading "point 4":** The earlier statement _"AP Incharge
> cannot directly manage roles in Chittoor"_ referenced a role by name and reads as
> a contradiction. Correct rule: **the child node's reporting head (whoever it is)
> and the child node's owner both have full authority over that child node's
> roles.** Any _other_ parent-node role does not.

### 7.4 Reporting Head is a **Hard Link** (full co-owner)

The reporting head is a **hard link** to the node owner:

- **Full co-owner** of the child node — can create / modify / remove that node's
  roles and has full operational control of the child node.
- Authority flows **only downward** into the child node it is linked to — **never
  upward** into the parent, and **never** into the child's children (that would be
  n-2).

### 7.5 Reporting-Head Rank is Unconstrained (intended)

A node owner may hard-link to **any** role in the parent node's hierarchy —
**including the lowest-ranked parent role**. This is **intended**: the reporting
head is a deliberate governance choice, not a rank-derived one. A junior parent
role may legitimately co-own a child node if the architect wires it that way.

### 7.6 Identity by Stable ID, Never by Name

Role names ("Incharge", "Captain", "President") are **arbitrary, display-only, and
collide across nodes**. The engine must key all authority on **stable IDs**:

- `owner_of(node)` and `reporting_head_of(node)` are resolved by ID.
- Names may be renamed freely without changing any authority.

### 7.7 Ownership Follows the Ordered List — Reordering Transfers Ownership (intended)

The owner is always the **top of the node's ordered role list**. If an architect
**reorders** roles later, ownership **moves** to whoever now sits at the top. This
is **intended**, but it is a high-impact action and MUST be gated by:

- an explicit **confirmation** step, and
- an **audit** log entry recording the ownership transfer.

### 7.8 Delete Policy — Reassign First, No Dangling Links (no re-parenting)

Structural deletes must never leave orphans or dangling reporting links.
**Re-parenting/moving a node is not supported (see §9.5)** — to relocate, delete
cleanly and recreate. Policy:

- **Delete a node with children** → delete **bottom-up**: cleanly remove or
  re-assign every descendant first (reassigning reporting heads so nothing is
  orphaned), _then_ delete the node. Children are **not** moved to a new parent.
- **Delete a role that is a reporting head** → first **reassign** the dependent
  child node's reporting head to another valid parent role, _then_ delete.
- **Never orphan a head** → any owner / reporting-head that others depend on must be
  **replaced (re-tagged) before removal**; there is always a tagged responsible
  party (see §9.3).
- In all cases: **reassign first, then delete.** No operation may leave a node
  without an owner or a dangling `reporting_head_of` link.

### 7.9 Structural Invariants (engine must enforce)

- **Fixed parent, strict tree** — a node's parent is set at creation and **cannot be
  changed** (no re-parenting; see §9.5); the node graph is an acyclic, single-parent
  tree.
- **Strict total order per node** — role ranks are unique within a node (no ties),
  so there is always exactly one top (owner) role.
- **Root exemption** — the root node (e.g., National) has no parent and therefore
  **no reporting head**; the parent-role-link requirement does not apply to it.

### 7.10 Updated Rule Summary (Consolidated)

| #   | Rule                                      | Clarification                                                                                                                                                                              |
| --- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 14  | **Two verticals**                         | Node vertical = single-level across nodes. Role vertical: owner/top role governs the whole node (node ownership); non-owner roles are single-level (control only the role directly below). |
| 15  | **Anchored notation**                     | `n+1` = parent (above), `n` = node, `n-1` = direct child (below); smaller index = child.                                                                                                   |
| 16  | **Node = owner + reporting head**         | Exactly two governing seats/roles govern a node (each may be multi-held); both single-level, downward-only.                                                                                |
| 17  | **Reporting head = hard link / co-owner** | Full operational control of the linked child node; never reaches the parent or n-2.                                                                                                        |
| 18  | **Reporting-head rank is free**           | A node owner may link to any parent role, including the lowest (intended).                                                                                                                 |
| 19  | **Identity by stable ID, not name**       | Authority resolves via `owner_of(node)` / `reporting_head_of(node)`; names are display-only.                                                                                               |
| 20  | **Reordering transfers ownership**        | Intended, but requires explicit confirmation + audit log.                                                                                                                                  |
| 21  | **Reassign before delete**                | Deleting a node/role first reassigns children/reporting heads; no orphans or dangling links.                                                                                               |
| 22  | **Structural invariants**                 | Strict tree (acyclic, single parent), unique role ranks per node, root has no reporting head.                                                                                              |

---

## 8. Lifecycle & State Rules (No Orphans, Ever)

> **Core invariant:** _At no point in time may any node, role, or record be
> orphaned._ Every node always has a parent (except the root) and is always
> governed by a live owner **or** its reporting head. The reporting head is the
> mechanism that guarantees this.

### 8.1 Vacancy is Never Orphaned — Reporting Head Guarantees Continuity

The reporting head exists primarily for continuity. A node's governance seat is
**never** allowed to go empty:

- **Proactive succession:** Before an owner leaves (e.g., `Ravi — Captain` of
  Chittoor resigns), the **reporting head assigns the new owner** (new Captain).
  Succession happens _at or before_ the moment of departure, not after.
- **No orphan window:** There is **no point in time** where the node has no
  governing authority. If the owner seat is momentarily empty, the **reporting
  head holds full authority** over the node until a new owner is assigned.
- **There is always a parent:** Every non-root node has a reporting head in its
  parent node, so authority can always be resolved upward — no record, role, or
  node is ever left without a responsible party.

> **Rule:** `owner_of(node)` may transiently be empty, but
> `reporting_head_of(node)` is always live for any non-root node, and it is the
> reporting head's duty to fill the owner seat. Root nodes must always have a live
> owner (they have no reporting head).

### 8.2 One Person = One Role = One Node (no multi-hat)

- A person holds **exactly one role**, in **exactly one node**.
- **No multi-role** (a person cannot hold two roles in the same node).
- **No multi-node** (a person cannot belong to more than one node).

**Implication:** Effective permission for any user is unambiguous — it is derived
solely from their single `(node, role)` assignment. The "senior in one branch,
junior in another" conflict cannot occur by construction.

### 8.3 Node Creation is Atomic (node + top role together)

Node creation is a **single atomic transaction**: a node and **at least its top
role (owner)** are committed **together, or not at all**.

- There is **no valid saved state** where a node exists without an owner role.
- If the transaction fails or is abandoned mid-way, the node is **not persisted**
  — no ghost/half-created nodes.

### 8.4 Ownerless / Broken Nodes are Not Self-Serviceable

Because atomic creation (8.3) and the no-orphan invariant (8.1) hold, an ownerless
node should never occur in normal operation. If one ever does (data corruption,
migration bug):

- It is **not directly visible or cleanable** by regular users — nobody has
  authority over an ownerless node.
- Recovery is handled **only by the support/platform team (us)** through an
  administrative path, not through the normal app flow.

### 8.5 Lifecycle Rule Summary

| #   | Rule                                  | Clarification                                                                                      |
| --- | ------------------------------------- | -------------------------------------------------------------------------------------------------- |
| 23  | **No orphans, ever**                  | Every non-root node always has a parent and a live governing party (owner or reporting head).      |
| 24  | **Reporting head ensures succession** | Reporting head assigns the new owner before/at departure; holds authority if the seat is empty.    |
| 25  | **One person, one role, one node**    | No multi-role, no multi-node; effective permission is derived from a single `(node, role)`.        |
| 26  | **Atomic node creation**              | A node and its top role commit together or not at all; no ownerless saved state.                   |
| 27  | **Broken nodes → support only**       | Ownerless/corrupt nodes are not user-serviceable; only the support/platform team can recover them. |

---

## 9. Cardinality, Parenting & Recovery Rules (Part B Decisions)

> These decisions cover role/person cardinality, node parenting, and the recovery
> paths for the few states the earlier sections could not resolve on their own.

### 9.1 A Role May Have Multiple Holders

- **One role can be held by multiple people** at the same time (e.g., many
  `Member`s, several `Supervisor`s).
- This is fully compatible with §8.2 (one **person** → one role, one node): a
  _person_ holds exactly one role, but a _role_ may be shared by many persons.
- The **owner / top role may also have multiple concurrent holders** — they are
  **co-owners with equal owner authority** over that node (the same equal-power
  model as the reporting head in §7.4). Any co-owner's action is valid; ownership
  checks resolve against the **set** of holders of the owner role.

### 9.2 Root Owner Succession (no reporting head above root)

The root node has no parent and **no reporting head** (§7.9, §8.1). If the root
owner (org creator) leaves, there is **no self-service succession**. Only two paths
exist:

1. **Delete the entire organization** and all its relations, or
2. The **support/platform team reassigns** the root owner.

> **Frozen root:** Until support reassigns, the org is **frozen at the root** — no
> self-service authority exists at the root level. This is the single accepted
> no-live-authority window, by design.

### 9.3 Removal Requires Reassignment First — Never Orphan a Tagged Party

- Any party that others depend on (a node **owner** or a **reporting head**) can
  **never be directly removed**.
- First **assign a new head/person**, tag them, and only **then** remove the old
  one.
- This directly answers reporting-head vacancy: if a parent role acting as a
  reporting head would become empty, a replacement must be tagged first. There is
  **always** a tagged responsible party — no removal may leave a parent or child
  orphaned.

### 9.4 Parenting is Enforced (node-type hierarchy is validated)

- A node **cannot** be attached under an arbitrary parent — the **node-type
  hierarchy is enforced**. A child node's type must be a valid child of its
  parent's type (e.g., a **Ward cannot be placed directly under a State** when the
  defined order is State → District → Mandal → Ward).
- The engine **must validate** the parent's node type at creation and **reject**
  any placement that violates the defined type hierarchy.

### 9.5 No Re-Parenting — Delete Cleanly & Recreate

- A node's parent is **fixed at creation**. Moving / re-parenting a node is **not
  supported**.
- To relocate a node, **delete it cleanly** (bottom-up, leaving no orphan records,
  reassigning heads as needed per §9.3) and **recreate** it from scratch, exactly
  as during first-time creation.

### 9.6 One Role as Reporting Head for Many Children (capped, configurable)

- A single parent role may serve as the **reporting head (co-owner) for many child
  nodes** (e.g., all districts' owners reporting to the same State role).
- This is **allowed up to a limit**. The limit is **configurable**; for now it
  defaults to a **large number** and can be tightened to a desired threshold later.

### 9.7 Reporting-Head Scope is Always n-1 (confirmed)

- A reporting head co-owns **only** the node it is linked to (n-1 from the parent).
  At **no point** does it govern that node's children (n-2). Confirms §7.4.

### 9.8 Registrant is the Root Owner

- The registering user (org architect) is **automatically the root node's owner**.
- The root owner can be **changed or removed only by the support/platform team**
  (consistent with §9.2).

### 9.9 Part B Rule Summary

| #   | Rule                                    | Clarification                                                                                                                                          |
| --- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 28  | **A role may have many holders**        | One role — including the owner role — can be held by multiple people (co-owners with equal authority); a person still holds only one role in one node. |
| 29  | **Root succession = delete or support** | No self-service root succession; either delete the whole org or support reassigns the root owner.                                                      |
| 30  | **Reassign before removal**             | Owners/reporting heads are re-tagged before removal; a node is never left orphaned.                                                                    |
| 31  | **Enforced parenting**                  | Node-type hierarchy is validated at creation; placements that violate the type order are rejected.                                                     |
| 32  | **No re-parenting**                     | Parent is fixed at creation; to relocate, delete cleanly (no orphans) and recreate.                                                                    |
| 33  | **Reporting-head fan-out is capped**    | One role may be reporting head for many children up to a configurable (currently large) limit.                                                         |
| 34  | **Reporting-head scope = n-1 only**     | A reporting head governs only its linked node, never that node's children (n-2).                                                                       |
| 35  | **Registrant = root owner**             | The registrant is automatically the root owner; changed/removed only by support.                                                                       |
