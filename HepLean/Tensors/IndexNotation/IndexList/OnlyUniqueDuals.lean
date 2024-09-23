/-
Copyright (c) 2024 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Tooby-Smith
-/
import HepLean.Tensors.IndexNotation.IndexList.CountId
import HepLean.Tensors.IndexNotation.IndexList.Contraction
import Mathlib.Algebra.Order.Ring.Defs
import Mathlib.Data.Finset.Sort
/-!

# withDuals equal to withUniqueDuals

In a permissible list of indices every index which has a dual has a unique dual.
This corresponds to the condition that `l.withDual = l.withUniqueDual`.

We prove lemmas relating to this condition.

-/

namespace IndexNotation

namespace IndexList

variable {X : Type} [IndexNotation X] [Fintype X] [DecidableEq X]
variable (l l2 l3 : IndexList X)

/-- The conditon on an index list which is true if and only if for every index with a dual,
  that dual is unique. -/
def OnlyUniqueDuals : Prop := l.withUniqueDual = l.withDual

namespace OnlyUniqueDuals

variable {l l2 l3 : IndexList X}

-- omit [IndexNotation X] [Fintype X]

-- omit [DecidableEq X] in
lemma iff_unique_forall :
    l.OnlyUniqueDuals ↔
    ∀ (i : l.withDual) j, l.AreDualInSelf i j → j = l.getDual? i := by
  refine Iff.intro (fun h i j hj => ?_) (fun h => ?_)
  · rw [OnlyUniqueDuals, @Finset.ext_iff] at h
    simp only [withUniqueDual, mem_withDual_iff_isSome, Finset.mem_filter, Finset.mem_univ,
      true_and, and_iff_left_iff_imp] at h
    refine h i ?_ j hj
    exact withDual_isSome l i
  · refine Finset.ext (fun i => ?_)
    refine Iff.intro (fun hi => mem_withDual_of_mem_withUniqueDual l i hi) (fun hi => ?_)
    · simp only [withUniqueDual, mem_withDual_iff_isSome, Finset.mem_filter, Finset.mem_univ,
        true_and]
      exact And.intro ((mem_withDual_iff_isSome l i).mp hi) (fun j hj => h ⟨i, hi⟩ j hj)

-- omit [DecidableEq X] in
lemma iff_countId_leq_two :
    l.OnlyUniqueDuals ↔ ∀ i, l.countId (l.val.get i) ≤ 2 := by
  refine Iff.intro (fun h i => ?_) (fun h => ?_)
  · by_cases hi : i ∈ l.withDual
    · rw [← h, mem_withUniqueDual_iff_countId_eq_two] at hi
      rw [hi]
    · rw [mem_withDual_iff_countId_gt_one] at hi
      exact Nat.le_of_not_ge hi
  · refine Finset.ext (fun i => ?_)
    rw [mem_withUniqueDual_iff_countId_eq_two, mem_withDual_iff_countId_gt_one]
    have hi := h i
    omega

lemma iff_countId_leq_two' : l.OnlyUniqueDuals ↔ ∀ I, l.countId I ≤ 2 := by
  rw [iff_countId_leq_two]
  refine Iff.intro (fun h I => ?_) (fun h i => h (l.val.get i))
  by_cases hI : l.countId I = 0
  · rw [hI]
    exact Nat.zero_le 2
  · obtain ⟨I', hI1', hI2'⟩ := countId_neq_zero_mem l I hI
    rw [countId_congr _ hI2']
    have hi : List.indexOf I' l.val < l.length := List.indexOf_lt_length.mpr hI1'
    have hI' : I' = l.val.get ⟨List.indexOf I' l.val, hi⟩ := (List.indexOf_get hi).symm
    rw [hI']
    exact h ⟨List.indexOf I' l.val, hi⟩

/-!

## On appended lists

-/

lemma inl (h : (l ++ l2).OnlyUniqueDuals) : l.OnlyUniqueDuals := by
  rw [iff_countId_leq_two'] at h ⊢
  intro I
  have hI := h I
  rw [countId_append] at hI
  exact (Nat.le_add_right _ _).trans hI

lemma inr (h : (l ++ l2).OnlyUniqueDuals) : l2.OnlyUniqueDuals := by
  rw [iff_countId_leq_two'] at h ⊢
  intro I
  have hI := h I
  rw [countId_append] at hI
  exact le_of_add_le_right hI

lemma symm' (h : (l ++ l2).OnlyUniqueDuals) : (l2 ++ l).OnlyUniqueDuals := by
  rw [iff_countId_leq_two'] at h ⊢
  intro I
  have hI := h I
  rw [countId_append] at hI
  simp only [countId_append, ge_iff_le]
  omega

lemma symm : (l ++ l2).OnlyUniqueDuals ↔ (l2 ++ l).OnlyUniqueDuals := by
  refine Iff.intro symm' symm'

lemma swap (h : (l ++ l2 ++ l3).OnlyUniqueDuals) : (l2 ++ l ++ l3).OnlyUniqueDuals := by
  rw [iff_countId_leq_two'] at h ⊢
  intro I
  have hI := h I
  simp only [countId_append] at hI
  simp only [countId_append, ge_iff_le]
  omega

/-!

## Contractions

-/

lemma contrIndexList (h : l.OnlyUniqueDuals) : l.contrIndexList.OnlyUniqueDuals := by
  rw [iff_countId_leq_two'] at h ⊢
  exact fun I => Nat.le_trans (countId_contrIndexList_le_countId l I) (h I)

lemma contrIndexList_left (h1 : (l ++ l2).OnlyUniqueDuals) :
    (l.contrIndexList ++ l2).OnlyUniqueDuals := by
  rw [iff_countId_leq_two'] at h1 ⊢
  intro I
  have hI := h1 I
  simp only [countId_append] at hI
  simp only [countId_append, ge_iff_le]
  have h1 := countId_contrIndexList_le_countId l I
  exact add_le_of_add_le_right hI h1

lemma contrIndexList_right (h1 : (l ++ l2).OnlyUniqueDuals) :
    (l ++ l2.contrIndexList).OnlyUniqueDuals := by
  rw [symm] at h1 ⊢
  exact contrIndexList_left h1

lemma contrIndexList_append (h1 : (l ++ l2).OnlyUniqueDuals) :
    (l.contrIndexList ++ l2.contrIndexList).OnlyUniqueDuals := by
  rw [iff_countId_leq_two'] at h1 ⊢
  intro I
  have hI := h1 I
  simp only [countId_append] at hI
  simp only [countId_append, ge_iff_le]
  have h1 := countId_contrIndexList_le_countId l I
  have h2 := countId_contrIndexList_le_countId l2 I
  omega

end OnlyUniqueDuals

-- omit [IndexNotation X] [Fintype X] in
lemma countId_of_OnlyUniqueDuals (h : l.OnlyUniqueDuals) (I : Index X) :
    l.countId I ≤ 2 := by
  rw [OnlyUniqueDuals.iff_countId_leq_two'] at h
  exact h I

-- omit [IndexNotation X] [Fintype X] in
lemma countId_eq_two_ofcontrIndexList_left_of_OnlyUniqueDuals
    (h : (l ++ l2).OnlyUniqueDuals) (I : Index X) (h' : (l.contrIndexList ++ l2).countId I = 2) :
    (l ++ l2).countId I = 2 := by
  simp only [countId_append]
  have h1 := countId_contrIndexList_le_countId l I
  have h3 := countId_of_OnlyUniqueDuals _ h I
  simp only [countId_append] at h3 h'
  omega

end IndexList

end IndexNotation
