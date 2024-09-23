/-
Copyright (c) 2024 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Tooby-Smith
-/
import Mathlib.Tactic.FinCases
/-!

# Index notation for a type

In this file we will define an index of a Lorentz tensor as a
string satisfying certain properties.

For example, the string `ᵘ¹²` is an index of a real Lorentz tensors.
The first character `ᵘ` specifies the color of the index, and the subsequent characters
`¹²` specify the id of the index.

Strings of indices e.g. `ᵘ¹²ᵤ₄₃`` are defined elsewhere.

-/

open Lean
open String

/-- The class defining index notation on a type `X`.
  Normally `X` will be taken as the type of colors of a `TensorStructure`. -/
class IndexNotation (X : Type) where
  /-- The list of characters describing the index notation e.g.
    `{'ᵘ', 'ᵤ'}` for real tensors. -/
  charList : Finset Char
  /-- An equivalence between `X` (colors of indices) and `charList`.
    This takes every color of index to its notation character. -/
  notaEquiv : X ≃ charList

namespace IndexNotation

variable (X : Type) [IndexNotation X]
variable [Fintype X] [DecidableEq X]

/-!

## Lists of characters forming an index

Here we define `listCharIndex` and properties thereof.

-/

/-- The map taking a color to its notation character. -/
def nota {X : Type} [IndexNotation X] (x : X) : Char :=
  (IndexNotation.notaEquiv).toFun x

/-- A character is a `notation character` if it is in `charList`. -/
def isNotationChar (c : Char) : Bool :=
  if c ∈ charList X then true else false

/-- A character is a numeric superscript if it is e.g. `⁰`, `¹`, etc. -/
def isNumericSupscript (c : Char) : Bool :=
  c = '¹' ∨ c = '²' ∨ c = '³' ∨ c = '⁴' ∨ c = '⁵' ∨ c = '⁶' ∨ c = '⁷' ∨ c = '⁸' ∨ c = '⁹' ∨ c = '⁰'

/-- Given a character `f` which is a notation character, this is true if `c`
  is a subscript when `f` is a subscript or `c` is a superscript when `f` is a
  superscript. -/
def IsIndexId (f : Char) (c : Char) : Bool :=
  (isSubScriptAlnum f ∧ isNumericSubscript c) ∨
  (¬ isSubScriptAlnum f ∧ isNumericSupscript c)

/-- The proposition for a list of characters to be the tail of an index
  e.g. `['¹', '⁷', ...]` -/
def listCharIndexTail (f : Char) (l : List Char) : Prop :=
  l ≠ [] ∧ List.all l (fun c => IsIndexId f c)

instance : Decidable (listCharIndexTail f l) := instDecidableAnd

/-- The proposition for a list of characters to be the characters of an index
  e.g. `['ᵘ', '¹', '⁷', ...]` -/
def listCharIndex (l : List Char) : Prop :=
  if h : l = [] then True
  else
    let sfst := l.head h
    if ¬ isNotationChar X sfst then False
    else
      listCharIndexTail sfst l.tail

-- omit [Fintype X] [DecidableEq X] in
/-- An auxillary rewrite lemma to prove that `listCharIndex` is decidable. -/
lemma listCharIndex_iff (l : List Char) : listCharIndex X l
    ↔ (if h : l = [] then True else
    let sfst := l.head h
    if ¬ isNotationChar X sfst then False
    else listCharIndexTail sfst l.tail) := by rfl

instance _root_.instDecidableDite {c : Prop} {t : c → Prop} {e : ¬c → Prop} [dC : Decidable c] [dT : ∀ h, Decidable (t h)] [dE : ∀ h, Decidable (e h)] : Decidable (if h : c then t h else e h)  :=
  match dC with
  | isTrue hc  => dT hc
  | isFalse hc => dE hc

instance : Decidable (listCharIndex X l) :=
  @decidable_of_decidable_of_iff _ _
    (@instDecidableDite _ _ _ _ _ <|
        fun _ => @instDecidableDite _ _ _ _ _ <|
        fun _ => instDecidableListCharIndexTail)
      (listCharIndex_iff X l).symm

/-!

## The definition of an index

-/

/-- An index for `X` is an pair of an element of `X` (the color of the index) and a natural
  number (the id of the index). -/
def Index : Type := X × ℕ

instance : DecidableEq (Index X) := instDecidableEqProd

namespace Index

variable {X : Type} [IndexNotation X] [Fintype X] [DecidableEq X]

/-- The color associated to an index. -/
def toColor (I : Index X) : X := I.1

/-- The natural number representating the id of an index. -/
def id (I : Index X) : ℕ := I.2

-- omit [IndexNotation X] [Fintype X] [DecidableEq X] in
lemma eq_iff_color_eq_and_id_eq (I J : Index X) : I = J ↔ I.toColor = J.toColor ∧ I.id = J.id := by
  refine Iff.intro (fun h => Prod.mk.inj_iff.mp h) (fun h => ?_)
  · cases I
    cases J
    simp only [toColor, id] at h
    simp [h]

end Index

/-!

## The definition of an index and its properties

-/

/-- An index rep is a non-empty string satisfying the condtion `listCharIndex`,
  e.g. `ᵘ¹²` or `ᵤ₄₃` etc. -/
def IndexRep : Type := {s : String // listCharIndex X s.toList ∧ s.toList ≠ []}

instance : DecidableEq (IndexRep X) :=
  fun ⟨a, h₁⟩ ⟨b, h₂⟩ =>
    if h : a = b then isTrue (by subst h; exact rfl)
    else isFalse (fun h' => Subtype.noConfusion h' (fun h' => absurd h' h))

namespace IndexRep

variable {X : Type} [IndexNotation X] [Fintype X] [DecidableEq X]

/-- Creats an index from a non-empty list of characters satisfying `listCharIndex`. -/
def ofCharList (l : List Char) (h : listCharIndex X l ∧ l ≠ []) : IndexRep X := ⟨l.asString, h⟩

instance : ToString (IndexRep X) := ⟨fun i => i.val⟩

/-- Gets the first character in an index e.g. `ᵘ` as an element of `charList X`. -/
def head (s : IndexRep X) : charList X :=
  ⟨s.val.toList.head (s.prop.2), by
    have h := s.prop.1
    have h2 := s.prop.2
    simp only [listCharIndex, toList, Bool.not_eq_true, ne_eq, if_false_left,
      Bool.not_eq_false] at h
    simp_all only [toList, ne_eq, Bool.not_eq_true, ↓reduceDite]
    simpa [isNotationChar] using h.1⟩

/-- The color associated to an index. -/
def toColor (s : IndexRep X) : X := (IndexNotation.notaEquiv).invFun s.head

/-- A map from super and subscript numerical characters to the natural numbers,
  returning `0` on all other characters. -/
def charToNat (c : Char) : Nat :=
  match c with
  | '₀' => 0
  | '₁' => 1
  | '₂' => 2
  | '₃' => 3
  | '₄' => 4
  | '₅' => 5
  | '₆' => 6
  | '₇' => 7
  | '₈' => 8
  | '₉' => 9
  | '⁰' => 0
  | '¹' => 1
  | '²' => 2
  | '³' => 3
  | '⁴' => 4
  | '⁵' => 5
  | '⁶' => 6
  | '⁷' => 7
  | '⁸' => 8
  | '⁹' => 9
  | _ => 0

/-- The numerical characters associated with an index. -/
def tail (s : IndexRep X) : List Char := s.val.toList.tail

/-- The natural numbers assocaited with an index. -/
def tailNat (s : IndexRep X) : List ℕ := s.tail.map charToNat

/-- The id of an index, as a natural number. -/
def id (s : IndexRep X) : ℕ := s.tailNat.foldl (fun a b => 10 * a + b) 0

/-- The index associated with a `IndexRep`. -/
def toIndex (s : IndexRep X) : Index X := (s.toColor, s.id)

end IndexRep
end IndexNotation
