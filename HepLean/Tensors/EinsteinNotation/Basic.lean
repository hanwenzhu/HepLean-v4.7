/-
Copyright (c) 2024 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Tooby-Smith
-/
import Mathlib.LinearAlgebra.StdBasis
import HepLean.Tensors.Basic
import Mathlib.LinearAlgebra.DirectSum.Finsupp
import Mathlib.LinearAlgebra.Finsupp
/-!

# Einstein notation for real tensors

Einstein notation is a specific example of index notation, with only one color.

In this file we define Einstein notation for generic ring `R`.

-/

open TensorProduct BigOperators

section Fintype

variable {α M : Type*} (R : Type*) [Fintype α] [Semiring R] [AddCommMonoid M] [Module R M]
variable (S : Type*) [Semiring S] [Module S M] [SMulCommClass R S M]
variable (v : α → M)

def Fintype.linearCombination : (α → M) →ₗ[S] (α → R) →ₗ[R] M where
  toFun v :=
    { toFun := fun f => ∑ i, f i • v i
      map_add' := fun f g => by simp_rw [← Finset.sum_add_distrib, ← add_smul]; rfl
      map_smul' := fun r f => by simp_rw [Finset.smul_sum, smul_smul]; rfl }
  map_add' u v := by ext; simp [Finset.sum_add_distrib, Pi.add_apply, smul_add]
  map_smul' r v := by ext; simp [Finset.smul_sum, smul_comm]

variable {S}

theorem Fintype.linearCombination_apply (f) : Fintype.linearCombination R S v f = ∑ i, f i • v i :=
  rfl

end Fintype

/-- Einstein tensors have only one color, corresponding to a `down` index. . -/
def einsteinTensorColor : TensorColor where
  Color := Unit
  τ a := a
  τ_involutive μ := by rfl

instance : Fintype einsteinTensorColor.Color := Unit.fintype

instance : DecidableEq einsteinTensorColor.Color := instDecidableEqPUnit

variable {R : Type} [CommSemiring R]

/-- The `TensorStructure` associated with `n`-dimensional tensors. -/
noncomputable def einsteinTensor (R : Type) [CommSemiring R] (n : ℕ) : TensorStructure R where
  toTensorColor := einsteinTensorColor
  ColorModule _ := Fin n → R
  colorModule_addCommMonoid _ := Pi.addCommMonoid
  colorModule_module _ := Pi.Function.module (Fin n) R R
  contrDual _ := TensorProduct.lift (Fintype.linearCombination R R)
  contrDual_symm a x y := by
    simp only [lift.tmul, Fintype.linearCombination_apply, smul_eq_mul, mul_comm, Equiv.cast_refl,
      Equiv.refl_apply]
  unit a := ∑ i, Pi.basisFun R (Fin n) i ⊗ₜ[R] Pi.basisFun R (Fin n) i
  unit_rid a x:= by
    simp only [Pi.basisFun_apply]
    rw [tmul_sum, map_sum]
    trans ∑ i, x i • Pi.basisFun R (Fin n) i
    · refine Finset.sum_congr rfl (fun i _ => ?_)
      simp only [TensorStructure.contrLeftAux, LinearEquiv.refl_toLinearMap, LinearMap.coe_comp,
        LinearEquiv.coe_coe, Function.comp_apply, assoc_symm_tmul, map_tmul, lift.tmul,
        Fintype.linearCombination_apply, LinearMap.stdBasis_apply', smul_eq_mul, ite_mul, one_mul,
        zero_mul, Finset.sum_ite_eq, Finset.mem_univ, ↓reduceIte, LinearMap.id_coe, id_eq, lid_tmul,
        Pi.basisFun_apply]
    · funext a
      simp only [Pi.basisFun_apply, Finset.sum_apply, Pi.smul_apply, LinearMap.stdBasis_apply',
        smul_eq_mul, mul_ite, mul_one, mul_zero, Finset.sum_ite_eq', Finset.mem_univ, ↓reduceIte]
  metric a := ∑ i, Pi.basisFun R (Fin n) i ⊗ₜ[R] Pi.basisFun R (Fin n) i
  metric_dual a := by
    simp only [Pi.basisFun_apply, map_sum, comm_tmul]
    rw [tmul_sum, map_sum]
    refine Finset.sum_congr rfl (fun i _ => ?_)
    rw [sum_tmul, map_sum, Fintype.sum_eq_single i]
    · simp only [TensorStructure.contrMidAux, LinearEquiv.refl_toLinearMap,
      TensorStructure.contrLeftAux, LinearMap.coe_comp, LinearEquiv.coe_coe, Function.comp_apply,
      assoc_tmul, map_tmul, LinearMap.id_coe, id_eq, assoc_symm_tmul, lift.tmul,
      Fintype.linearCombination_apply, LinearMap.stdBasis_apply', smul_eq_mul, mul_ite, mul_one,
      mul_zero, Finset.sum_ite_eq, Finset.mem_univ, ↓reduceIte, lid_tmul, one_smul]
    · intro x hi
      simp only [TensorStructure.contrMidAux, LinearEquiv.refl_toLinearMap,
        TensorStructure.contrLeftAux, LinearMap.coe_comp, LinearEquiv.coe_coe, Function.comp_apply,
        assoc_tmul, map_tmul, LinearMap.id_coe, id_eq, assoc_symm_tmul, lift.tmul,
        Fintype.linearCombination_apply, LinearMap.stdBasis_apply', smul_eq_mul, mul_ite, mul_one,
        mul_zero, Finset.sum_ite_eq, Finset.mem_univ, ↓reduceIte, lid_tmul, ite_smul, one_smul,
        zero_smul]
      rw [if_neg hi.symm]
      exact tmul_zero (Fin n → R) (Pi.single x 1)

namespace einsteinTensor

open TensorStructure

noncomputable section

instance instOfNatColorEinsteinTensorColorOfNatNat : OfNat einsteinTensorColor.Color 0 := ⟨PUnit.unit⟩
instance instOfNatColorOfNatNat : OfNat (einsteinTensor R n).Color 0 := ⟨PUnit.unit⟩

@[simp]
lemma ofNat_inst_eq : @einsteinTensor.instOfNatColorOfNatNat R _ n =
    einsteinTensor.instOfNatColorEinsteinTensorColorOfNatNat := rfl

/-- A vector from an Einstein tensor with one index. -/
def toVec : (einsteinTensor R n).Tensor ![Unit.unit] ≃ₗ[R] Fin n → R :=
  PiTensorProduct.subsingletonEquiv 0

/-- A matrix from an Einstein tensor with two indices. -/
def toMatrix : (einsteinTensor R n).Tensor ![Unit.unit, Unit.unit] ≃ₗ[R] Matrix (Fin n) (Fin n) R :=
  ((einsteinTensor R n).mapIso ((Fin.castIso
    (by rfl : (Nat.succ 0).succ = Nat.succ 0 + Nat.succ 0)).toEquiv.trans
      finSumFinEquiv.symm) (by funext x; fin_cases x <;> rfl)).trans <|
  ((einsteinTensor R n).tensoratorEquiv ![0] ![0]).symm.trans <|
  (TensorProduct.congr ((PiTensorProduct.subsingletonEquiv 0))
    ((PiTensorProduct.subsingletonEquiv 0))).trans <|
  (TensorProduct.congr (Finsupp.linearEquivFunOnFinite R R (Fin n)).symm
    (Finsupp.linearEquivFunOnFinite R R (Fin n)).symm).trans <|
  (finsuppTensorFinsupp' R (Fin n) (Fin n)).trans <|
  (Finsupp.linearEquivFunOnFinite R R (Fin n × Fin n)).trans <|
  (LinearEquiv.curry R (Fin n) (Fin n))

end

end einsteinTensor
