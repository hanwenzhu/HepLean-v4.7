/-
Copyright (c) 2024 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Tooby-Smith
-/
import Mathlib.LinearAlgebra.UnitaryGroup
import Mathlib.Data.Complex.Exponential
import Mathlib.Tactic.Polyrith
/-!
# The CKM Matrix

The definition of the type of CKM matrices as unitary $3×3$-matrices.

An equivalence relation on CKM matrices is defined, where two matrices are equivalent if they are
related by phase shifts.

The notation `[V]ud` etc can be used for the elements of a CKM matrix, and
`[V]ud|us` etc for the ratios of elements.

-/

open Matrix Complex

noncomputable section

/-- Given three real numbers `a b c` the complex matrix with `exp (I * a)` etc on the
leading diagonal. -/
@[simp]
def phaseShiftMatrix (a b c : ℝ) : Matrix (Fin 3) (Fin 3) ℂ :=
  ![![cexp (I * a), 0, 0], ![0, cexp (I * b), 0], ![0, 0, cexp (I * c)]]

lemma phaseShiftMatrix_one : phaseShiftMatrix 0 0 0 = 1 := by
  ext i j
  fin_cases i <;> fin_cases j
  any_goals rfl
  · simp only [phaseShiftMatrix, ofReal_zero, mul_zero, exp_zero, Fin.zero_eta, Fin.isValue,
    cons_val', cons_val_zero, empty_val', cons_val_fin_one, vecCons_const, one_apply_eq]
  · simp only [phaseShiftMatrix, ofReal_zero, mul_zero, exp_zero, Fin.mk_one, Fin.isValue,
    cons_val', cons_val_one, head_cons, empty_val', cons_val_fin_one, one_apply_eq]
  · simp only [phaseShiftMatrix, ofReal_zero, mul_zero, exp_zero, Fin.reduceFinMk, cons_val',
    Fin.isValue, cons_val_two, Nat.succ_eq_add_one, Nat.reduceAdd, tail_cons, head_cons, empty_val',
    cons_val_fin_one, head_fin_const, one_apply_eq]

lemma phaseShiftMatrix_star (a b c : ℝ) :
    (phaseShiftMatrix a b c)ᴴ = phaseShiftMatrix (- a) (- b) (- c) := by
  funext i j
  fin_cases i <;> fin_cases j <;>
  simp [← exp_conj, conj_ofReal]
  · rfl
  · rfl

lemma phaseShiftMatrix_mul (a b c d e f : ℝ) :
    phaseShiftMatrix a b c * phaseShiftMatrix d e f = phaseShiftMatrix (a + d) (b + e) (c + f) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
  simp [Matrix.mul_apply, Fin.sum_univ_three]
  any_goals rw [mul_add, exp_add]
  change cexp (I * ↑c) * 0 = 0
  simp

/-- Given three real numbers `a b c` the unitary matrix with `exp (I * a)` etc on the
leading diagonal. -/
@[simps!]
def phaseShift (a b c : ℝ) : unitaryGroup (Fin 3) ℂ :=
  ⟨phaseShiftMatrix a b c,
  by
    rw [mem_unitaryGroup_iff]
    change _ * (phaseShiftMatrix a b c)ᴴ = 1
    rw [phaseShiftMatrix_star, phaseShiftMatrix_mul, ← phaseShiftMatrix_one]
    simp only [phaseShiftMatrix, add_neg_self, ofReal_zero, mul_zero, exp_zero]⟩

lemma phaseShift_coe_matrix (a b c : ℝ) : ↑(phaseShift a b c) = phaseShiftMatrix a b c := rfl

/-- The equivalence relation between CKM matrices. -/
def PhaseShiftRelation (U V : unitaryGroup (Fin 3) ℂ) : Prop :=
  ∃ a b c e f g, U = phaseShift a b c * V * phaseShift e f g

lemma phaseShiftRelation_refl (U : unitaryGroup (Fin 3) ℂ) : PhaseShiftRelation U U := by
  use 0, 0, 0, 0, 0, 0
  rw [Subtype.ext_iff_val]
  simp only [Submonoid.coe_mul, phaseShift_coe_matrix, ofReal_zero, mul_zero, exp_zero]
  rw [phaseShiftMatrix_one]
  simp only [one_mul, mul_one]

lemma phaseShiftRelation_symm {U V : unitaryGroup (Fin 3) ℂ} :
    PhaseShiftRelation U V → PhaseShiftRelation V U := by
  intro h
  obtain ⟨a, b, c, e, f, g, h⟩ := h
  use (- a), (- b), (- c), (- e), (- f), (- g)
  rw [Subtype.ext_iff_val]
  rw [h]
  repeat rw [mul_assoc]
  simp only [Submonoid.coe_mul, phaseShift_coe_matrix, ofReal_neg, mul_neg]
  rw [phaseShiftMatrix_mul]
  repeat rw [← mul_assoc]
  simp only [phaseShiftMatrix_mul, add_neg_self, phaseShiftMatrix_one, one_mul,
    mul_one, neg_add_self]

lemma phaseShiftRelation_trans {U V W : unitaryGroup (Fin 3) ℂ} :
    PhaseShiftRelation U V → PhaseShiftRelation V W → PhaseShiftRelation U W := by
  intro hUV hVW
  obtain ⟨a, b, c, e, f, g, hUV⟩ := hUV
  obtain ⟨d, i, j, k, l, m, hVW⟩ := hVW
  use (a + d), (b + i), (c + j), (e + k), (f + l), (g + m)
  rw [Subtype.ext_iff_val, hUV, hVW]
  simp only [Submonoid.coe_mul, phaseShift_coe_matrix]
  rw [mul_assoc, mul_assoc, phaseShiftMatrix_mul, ← mul_assoc, ← mul_assoc, phaseShiftMatrix_mul,
    add_comm k e, add_comm l f, add_comm m g]

lemma phaseShiftRelation_equiv : Equivalence PhaseShiftRelation where
  refl := phaseShiftRelation_refl
  symm := phaseShiftRelation_symm
  trans := phaseShiftRelation_trans

/-- The type of CKM matrices. -/
def CKMMatrix : Type := unitaryGroup (Fin 3) ℂ

lemma CKMMatrix_ext {U V : CKMMatrix} (h : U.val = V.val) : U = V := by
  cases U; cases V
  simp at h
  subst h
  rfl

/-- The `ud`th element of the CKM matrix. -/
scoped[CKMMatrix] notation (name := ud_element) "[" V "]ud" => V.1 0 0

/-- The `us`th element of the CKM matrix. -/
scoped[CKMMatrix] notation (name := us_element) "[" V "]us" => V.1 0 1

/-- The `ub`th element of the CKM matrix. -/
scoped[CKMMatrix] notation (name := ub_element) "[" V "]ub" => V.1 0 2

/-- The `cd`th element of the CKM matrix. -/
scoped[CKMMatrix] notation (name := cd_element) "[" V "]cd" => V.1 1 0

/-- The `cs`th element of the CKM matrix. -/
scoped[CKMMatrix] notation (name := cs_element) "[" V "]cs" => V.1 1 1

/-- The `cb`th element of the CKM matrix. -/
scoped[CKMMatrix] notation (name := cb_element) "[" V "]cb" => V.1 1 2

/-- The `td`th element of the CKM matrix. -/
scoped[CKMMatrix] notation (name := td_element) "[" V "]td" => V.1 2 0

/-- The `ts`th element of the CKM matrix. -/
scoped[CKMMatrix] notation (name := ts_element) "[" V "]ts" => V.1 2 1

/-- The `tb`th element of the CKM matrix. -/
scoped[CKMMatrix] notation (name := tb_element) "[" V "]tb" => V.1 2 2

instance CKMMatrixSetoid : Setoid CKMMatrix := ⟨PhaseShiftRelation, phaseShiftRelation_equiv⟩

/-- The matrix obtained from `V` by shifting the phases of the fermions. -/
@[simps!]
def phaseShiftApply (V : CKMMatrix) (a b c d e f : ℝ) : CKMMatrix :=
    phaseShift a b c * ↑V * phaseShift d e f

namespace phaseShiftApply
lemma equiv (V : CKMMatrix) (a b c d e f : ℝ) :
    V ≈ phaseShiftApply V a b c d e f := by
  symm
  use a, b, c, d, e, f
  rfl

lemma ud (V : CKMMatrix) (a b c d e f : ℝ) :
    (phaseShiftApply V a b c d e f).1 0 0 = cexp (a * I + d * I) * V.1 0 0 := by
  simp only [Fin.isValue, phaseShiftApply_coe]
  rw [mul_apply, Fin.sum_univ_three]
  rw [mul_apply, mul_apply, mul_apply, Fin.sum_univ_three, Fin.sum_univ_three, Fin.sum_univ_three]
  simp only [Fin.isValue, cons_val', cons_val_zero, empty_val', cons_val_fin_one, vecCons_const,
    cons_val_one, head_cons, zero_mul, add_zero, cons_val_two, tail_cons, head_fin_const, mul_zero,
    tail_val', head_val']
  change _ + _ * _ * 0 = _
  rw [exp_add]
  ring_nf

lemma us (V : CKMMatrix) (a b c d e f : ℝ) :
    (phaseShiftApply V a b c d e f).1 0 1 = cexp (a * I + e * I) * V.1 0 1 := by
  simp only [Fin.isValue, phaseShiftApply_coe]
  rw [mul_apply, Fin.sum_univ_three]
  rw [mul_apply, mul_apply, mul_apply, Fin.sum_univ_three, Fin.sum_univ_three, Fin.sum_univ_three]
  simp only [Fin.isValue, cons_val', cons_val_zero, empty_val', cons_val_fin_one, vecCons_const,
    cons_val_one, head_cons, zero_mul, add_zero, cons_val_two, tail_cons, mul_zero, zero_add,
    head_fin_const]
  rw [exp_add]
  ring_nf

lemma ub (V : CKMMatrix) (a b c d e f : ℝ) :
    (phaseShiftApply V a b c d e f).1 0 2 = cexp (a * I + f * I) * V.1 0 2 := by
  simp only [Fin.isValue, phaseShiftApply_coe]
  rw [mul_apply, Fin.sum_univ_three]
  rw [mul_apply, mul_apply, mul_apply, Fin.sum_univ_three, Fin.sum_univ_three, Fin.sum_univ_three]
  simp only [Fin.isValue, cons_val', cons_val_zero, empty_val', cons_val_fin_one, vecCons_const,
    cons_val_one, head_cons, zero_mul, add_zero, cons_val_two, tail_cons, mul_zero, head_fin_const,
    zero_add]
  rw [exp_add]
  ring_nf

lemma cd (V : CKMMatrix) (a b c d e f : ℝ) :
    (phaseShiftApply V a b c d e f).1 1 0= cexp (b * I + d * I) * V.1 1 0 := by
  simp only [Fin.isValue, phaseShiftApply_coe]
  rw [mul_apply, Fin.sum_univ_three]
  rw [mul_apply, mul_apply, mul_apply, Fin.sum_univ_three, Fin.sum_univ_three, Fin.sum_univ_three]
  simp only [Fin.isValue, cons_val', cons_val_zero, empty_val', cons_val_fin_one, vecCons_const,
    cons_val_one, head_fin_const, zero_mul, head_cons, zero_add, cons_val_two, tail_cons, add_zero,
    mul_zero, tail_val', head_val']
  change _ + _ * _ * 0 = _
  rw [exp_add]
  ring_nf

lemma cs (V : CKMMatrix) (a b c d e f : ℝ) :
    (phaseShiftApply V a b c d e f).1 1 1 = cexp (b * I + e * I) * V.1 1 1 := by
  simp only [Fin.isValue, phaseShiftApply_coe]
  rw [mul_apply, Fin.sum_univ_three]
  rw [mul_apply, mul_apply, mul_apply, Fin.sum_univ_three, Fin.sum_univ_three, Fin.sum_univ_three]
  simp only [Fin.isValue, cons_val', cons_val_zero, empty_val', cons_val_fin_one, vecCons_const,
    cons_val_one, head_fin_const, zero_mul, head_cons, zero_add, cons_val_two, tail_cons, add_zero,
    mul_zero]
  rw [exp_add]
  ring_nf

lemma cb (V : CKMMatrix) (a b c d e f : ℝ) :
    (phaseShiftApply V a b c d e f).1 1 2 = cexp (b * I + f * I) * V.1 1 2 := by
  simp only [Fin.isValue, phaseShiftApply_coe]
  rw [mul_apply, Fin.sum_univ_three]
  rw [mul_apply, mul_apply, mul_apply, Fin.sum_univ_three, Fin.sum_univ_three, Fin.sum_univ_three]
  simp only [Fin.isValue, cons_val', cons_val_zero, empty_val', cons_val_fin_one, vecCons_const,
    cons_val_one, head_fin_const, zero_mul, head_cons, zero_add, cons_val_two, tail_cons, add_zero,
    mul_zero]
  rw [exp_add]
  ring_nf

lemma td (V : CKMMatrix) (a b c d e f : ℝ) :
    (phaseShiftApply V a b c d e f).1 2 0= cexp (c * I + d * I) * V.1 2 0 := by
  simp only [Fin.isValue, phaseShiftApply_coe]
  rw [mul_apply, Fin.sum_univ_three]
  rw [mul_apply, mul_apply, mul_apply, Fin.sum_univ_three, Fin.sum_univ_three, Fin.sum_univ_three]
  simp only [Fin.isValue, cons_val', cons_val_zero, empty_val', cons_val_fin_one, vecCons_const,
    cons_val_two, tail_val', head_val', cons_val_one, head_cons, tail_cons, head_fin_const,
    zero_mul, add_zero, mul_zero]
  change (0 * _ + _) * _ + (0 * _ + _) * 0 = _
  simp only [Fin.isValue, zero_mul, zero_add, mul_zero, add_zero]
  rw [exp_add]
  ring_nf

lemma ts (V : CKMMatrix) (a b c d e f : ℝ) :
    (phaseShiftApply V a b c d e f).1 2 1 = cexp (c * I + e * I) * V.1 2 1 := by
  simp only [Fin.isValue, phaseShiftApply_coe]
  rw [mul_apply, Fin.sum_univ_three]
  rw [mul_apply, mul_apply, mul_apply, Fin.sum_univ_three, Fin.sum_univ_three, Fin.sum_univ_three]
  simp only [Fin.isValue, cons_val', cons_val_zero, empty_val', cons_val_fin_one, vecCons_const,
    cons_val_two, tail_val', head_val', cons_val_one, head_cons, tail_cons, head_fin_const,
    zero_mul, add_zero, mul_zero, zero_add]
  change (0 * _ + _) * _ = _
  rw [exp_add]
  ring_nf

lemma tb (V : CKMMatrix) (a b c d e f : ℝ) :
    (phaseShiftApply V a b c d e f).1 2 2 = cexp (c * I + f * I) * V.1 2 2 := by
  simp only [Fin.isValue, phaseShiftApply_coe]
  rw [mul_apply, Fin.sum_univ_three]
  rw [mul_apply, mul_apply, mul_apply, Fin.sum_univ_three, Fin.sum_univ_three, Fin.sum_univ_three]
  simp only [Fin.isValue, cons_val', cons_val_zero, empty_val', cons_val_fin_one, vecCons_const,
    cons_val_two, tail_val', head_val', cons_val_one, head_cons, tail_cons, head_fin_const,
    zero_mul, add_zero, mul_zero, zero_add]
  change (0 * _ + _) * _ = _
  rw [exp_add]
  ring_nf

end phaseShiftApply

/-- The aboslute value of the `(i,j)`th element of `V`. -/
@[simp]
def VAbs' (V : unitaryGroup (Fin 3) ℂ) (i j : Fin 3) : ℝ := Complex.abs (V i j)

lemma VAbs'_equiv (i j : Fin 3) (V U : CKMMatrix) (h : V ≈ U) :
    VAbs' V i j = VAbs' U i j := by
  simp only [VAbs']
  obtain ⟨a, b, c, e, f, g, h⟩ := h
  rw [h]
  simp only [Submonoid.coe_mul, phaseShift_coe_matrix]
  rw [mul_apply, Fin.sum_univ_three]
  rw [mul_apply, Fin.sum_univ_three]
  rw [mul_apply, mul_apply, Fin.sum_univ_three, Fin.sum_univ_three]
  simp only [phaseShiftMatrix, Fin.isValue, cons_val', cons_val_zero, empty_val', cons_val_fin_one,
    vecCons_const, cons_val_one, head_cons, zero_mul, add_zero, cons_val_two, tail_cons,
    head_fin_const, mul_zero]
  fin_cases i <;> fin_cases j <;>
  simp [Complex.abs_exp]
  all_goals change Complex.abs (0 * _ + _) = _
  all_goals simp [Complex.abs_exp]

/-- The absolute value of the `(i,j)`th any representative of `⟦V⟧`. -/
def VAbs (i j : Fin 3) : Quotient CKMMatrixSetoid → ℝ :=
  Quotient.lift (fun V => VAbs' V i j) (VAbs'_equiv i j)

/-- The absolute value of the `ud`th element of a representative of an equivalence class of
  CKM matrices. -/
@[simp]
abbrev VudAbs := VAbs 0 0

/-- The absolute value of the `us`th element of a representative of an equivalence class of
  CKM matrices. -/
@[simp]
abbrev VusAbs := VAbs 0 1

/-- The absolute value of the `ub`th element of a representative of an equivalence class of
  CKM matrices. -/
@[simp]
abbrev VubAbs := VAbs 0 2

/-- The absolute value of the `cd`th element of a representative of an equivalence class of
  CKM matrices. -/
@[simp]
abbrev VcdAbs := VAbs 1 0

/-- The absolute value of the `cs`th element of a representative of an equivalence class of
  CKM matrices. -/
@[simp]
abbrev VcsAbs := VAbs 1 1

/-- The absolute value of the `cb`th element of a representative of an equivalence class of
  CKM matrices. -/
@[simp]
abbrev VcbAbs := VAbs 1 2

/-- The absolute value of the `td`th element of a representative of an equivalence class of
  CKM matrices. -/
@[simp]
abbrev VtdAbs := VAbs 2 0

/-- The absolute value of the `ts`th element of a representative of an equivalence class of
  CKM matrices. -/
@[simp]
abbrev VtsAbs := VAbs 2 1

/-- The absolute value of the `tb`th element of a representative of an equivalence class of
  CKM matrices. -/
@[simp]
abbrev VtbAbs := VAbs 2 2

namespace CKMMatrix
open ComplexConjugate

section ratios

/-- The ratio of the `ub` and `ud` elements of a CKM matrix. -/
def Rubud (V : CKMMatrix) : ℂ := [V]ub / [V]ud

/-- The ratio of the `ub` and `ud` elements of a CKM matrix. -/
scoped[CKMMatrix] notation (name := ub_ud_ratio) "[" V "]ub|ud" => Rubud V

/-- The ratio of the `us` and `ud` elements of a CKM matrix. -/
def Rusud (V : CKMMatrix) : ℂ := [V]us / [V]ud

/-- The ratio of the `us` and `ud` elements of a CKM matrix. -/
scoped[CKMMatrix] notation (name := us_ud_ratio) "[" V "]us|ud" => Rusud V

/-- The ratio of the `ud` and `us` elements of a CKM matrix. -/
def Rudus (V : CKMMatrix) : ℂ := [V]ud / [V]us

/-- The ratio of the `ud` and `us` elements of a CKM matrix. -/
scoped[CKMMatrix] notation (name := ud_us_ratio) "[" V "]ud|us" => Rudus V

/-- The ratio of the `ub` and `us` elements of a CKM matrix. -/
def Rubus (V : CKMMatrix) : ℂ := [V]ub / [V]us

/-- The ratio of the `ub` and `us` elements of a CKM matrix. -/
scoped[CKMMatrix] notation (name := ub_us_ratio) "[" V "]ub|us" => Rubus V

/-- The ratio of the `cd` and `cb` elements of a CKM matrix. -/
def Rcdcb (V : CKMMatrix) : ℂ := [V]cd / [V]cb

/-- The ratio of the `cd` and `cb` elements of a CKM matrix. -/
scoped[CKMMatrix] notation (name := cd_cb_ratio) "[" V "]cd|cb" => Rcdcb V

lemma Rcdcb_mul_cb {V : CKMMatrix} (h : [V]cb ≠ 0) : [V]cd = Rcdcb V * [V]cb := by
  rw [Rcdcb]
  exact (div_mul_cancel₀ (V.1 1 0) h).symm

/-- The ratio of the `cs` and `cb` elements of a CKM matrix. -/
def Rcscb (V : CKMMatrix) : ℂ := [V]cs / [V]cb

/-- The ratio of the `cs` and `cb` elements of a CKM matrix. -/
scoped[CKMMatrix] notation (name := cs_cb_ratio) "[" V "]cs|cb" => Rcscb V

lemma Rcscb_mul_cb {V : CKMMatrix} (h : [V]cb ≠ 0) : [V]cs = Rcscb V * [V]cb := by
  rw [Rcscb]
  exact (div_mul_cancel₀ [V]cs h).symm

end ratios

end CKMMatrix

end
