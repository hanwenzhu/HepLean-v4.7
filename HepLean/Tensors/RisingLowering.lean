/-
Copyright (c) 2024 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Tooby-Smith
-/
import HepLean.Tensors.MulActionTensor
/-!

# Rising and Lowering of indices

We use the term `dualize` to describe the more general version of rising and lowering of indices.

In particular, rising and lowering indices corresponds taking the color of that index
to its dual.

-/

noncomputable section

open TensorProduct

namespace TensorColor

variable {𝓒 : TensorColor} [DecidableEq 𝓒.Color] [Fintype 𝓒.Color]

variable {d : ℕ} {X Y Y' Z W C P : Type} [Fintype X] [DecidableEq X] [Fintype Y] [DecidableEq Y]
  [Fintype Y'] [DecidableEq Y'] [Fintype Z] [DecidableEq Z] [Fintype W] [DecidableEq W]
  [Fintype C] [DecidableEq C] [Fintype P] [DecidableEq P]

/-!

## Dual maps

-/

namespace ColorMap

variable (cX : 𝓒.ColorMap X)

/-- Given an equivalence `C ⊕ P ≃ X` the color map obtained by `cX` by dualising
  all indices in `C`. -/
def partDual (e : C ⊕ P ≃ X) : 𝓒.ColorMap X :=
  (Sum.elim (𝓒.τ ∘ cX ∘ e ∘ Sum.inl) (cX ∘ e ∘ Sum.inr) ∘ e.symm)

/-- Two color maps are said to be dual if their quotents are dual. -/
def DualMap (c₁ c₂ : 𝓒.ColorMap X) : Prop :=
  𝓒.colorQuot ∘ c₁ = 𝓒.colorQuot ∘ c₂

namespace DualMap

variable {c₁ c₂ c₃ : 𝓒.ColorMap X}
variable {n : ℕ}

/-- The bool which if `𝓒.colorQuot (c₁ i) = 𝓒.colorQuot (c₂ i)` is true for all `i`. -/
def boolFin (c₁ c₂ : 𝓒.ColorMap (Fin n)) : Bool :=
  (Fin.list n).all fun i => if 𝓒.colorQuot (c₁ i) = 𝓒.colorQuot (c₂ i) then true else false

-- omit [Fintype 𝓒.Color] in
lemma boolFin_DualMap {c₁ c₂ : 𝓒.ColorMap (Fin n)} (h : boolFin c₁ c₂ = true) :
    DualMap c₁ c₂ := by
  simp only [boolFin, List.all_eq_true, ite_eq_left_iff, imp_false, not_not] at h
  simp only [DualMap]
  funext x
  have h2 {n : ℕ} (m : Fin n) : m ∈ Fin.list n := by
    have h1' : (Fin.list n)[m] = m := by
      simp
    rw [← h1']
    apply List.get_mem
  exact h x (h2 _)

/-- The bool which is ture if `𝓒.colorQuot (c₁ i) = 𝓒.colorQuot (c₂ i)` is true for all `i`. -/
def boolFin' (c₁ c₂ : 𝓒.ColorMap (Fin n)) : Bool :=
  ∀ (i : Fin n), 𝓒.colorQuot (c₁ i) = 𝓒.colorQuot (c₂ i)

-- omit [Fintype 𝓒.Color]
lemma boolFin'_DualMap {c₁ c₂ : 𝓒.ColorMap (Fin n)} (h : boolFin' c₁ c₂ = true) :
    DualMap c₁ c₂ := by
  simp only [boolFin', decide_eq_true_eq] at h
  simp only [DualMap]
  funext x
  exact h x

-- omit [DecidableEq 𝓒.Color] [Fintype X] [DecidableEq X] in
lemma refl : DualMap c₁ c₁ := rfl

-- omit [DecidableEq 𝓒.Color] [Fintype X] [DecidableEq X] in
lemma symm (h : DualMap c₁ c₂) : DualMap c₂ c₁ := by
  rw [DualMap] at h ⊢
  exact h.symm

-- omit [DecidableEq 𝓒.Color] [Fintype X] [DecidableEq X] in
lemma trans (h : DualMap c₁ c₂) (h' : DualMap c₂ c₃) : DualMap c₁ c₃ := by
  rw [DualMap] at h h' ⊢
  exact h.trans h'

/-- The splitting of `X` given two color maps based on the equality of the color. -/
def split (c₁ c₂ : 𝓒.ColorMap X) : { x // c₁ x ≠ c₂ x} ⊕ { x // c₁ x = c₂ x} ≃ X :=
  ((Equiv.Set.sumCompl {x | c₁ x = c₂ x}).symm.trans (Equiv.sumComm _ _)).symm

-- omit [DecidableEq 𝓒.Color] [Fintype X] [DecidableEq X] in
lemma dual_eq_of_neq (h : DualMap c₁ c₂) {x : X} (h' : c₁ x ≠ c₂ x) :
    𝓒.τ (c₁ x) = c₂ x := by
  rw [DualMap] at h
  have h1 := congrFun h x
  simp only [Function.comp_apply, colorQuot, Quotient.eq, HasEquiv.Equiv, Setoid.r, colorRel] at h1
  simp_all only [ne_eq, false_or]
  exact 𝓒.τ_involutive (c₂ x)

-- omit [Fintype X] [DecidableEq X] in
@[simp]
lemma split_dual (h : DualMap c₁ c₂) : c₁.partDual (split c₁ c₂) = c₂ := by
  rw [partDual, Equiv.comp_symm_eq]
  funext x
  match x with
  | Sum.inl x =>
    exact h.dual_eq_of_neq x.2
  | Sum.inr x =>
    exact x.2

-- omit [Fintype X] [DecidableEq X] in
@[simp]
lemma split_dual' (h : DualMap c₁ c₂) : c₂.partDual (split c₁ c₂) = c₁ := by
  rw [partDual, Equiv.comp_symm_eq]
  funext x
  match x with
  | Sum.inl x =>
    change 𝓒.τ (c₂ x) = c₁ x
    rw [← h.dual_eq_of_neq x.2]
    exact (𝓒.τ_involutive (c₁ x))
  | Sum.inr x =>
    exact x.2.symm

end DualMap

end ColorMap
end TensorColor

variable {R : Type} [CommSemiring R]

namespace TensorStructure

variable (𝓣 : TensorStructure R)

variable {d : ℕ} {X Y Y' Z W C P : Type} [Fintype X] [DecidableEq X] [Fintype Y] [DecidableEq Y]
  [Fintype Y'] [DecidableEq Y'] [Fintype Z] [DecidableEq Z] [Fintype W] [DecidableEq W]
  [Fintype C] [DecidableEq C] [Fintype P] [DecidableEq P]
  {cX cX2 : 𝓣.ColorMap X} {cY : 𝓣.ColorMap Y} {cZ : 𝓣.ColorMap Z}
  {cW : 𝓣.ColorMap W} {cY' : 𝓣.ColorMap Y'} {μ ν: 𝓣.Color}

variable {G H : Type} [Group G] [Group H] [MulActionTensor G 𝓣]
local infixl:101 " • " => 𝓣.rep

/-!

## Properties of the unit

-/

/-! TODO: Move -/
lemma unit_lhs_eq (x : 𝓣.ColorModule μ) (y : 𝓣.ColorModule (𝓣.τ μ) ⊗[R] 𝓣.ColorModule μ) :
    contrLeftAux (𝓣.contrDual μ) (x ⊗ₜ[R] y) =
    (contrRightAux (𝓣.contrDual (𝓣.τ μ))) ((TensorProduct.comm R _ _) y
    ⊗ₜ[R] (𝓣.colorModuleCast (𝓣.τ_involutive μ).symm) x) := by
  refine TensorProduct.induction_on y (by rfl) ?_ (fun z1 z2 h1 h2 => ?_)
  · intro x1 x2
    simp only [contrRightAux, LinearEquiv.refl_toLinearMap, comm_tmul, colorModuleCast,
      Equiv.cast_symm, LinearEquiv.coe_mk, Equiv.cast_apply, LinearMap.coe_comp,
      LinearEquiv.coe_coe, Function.comp_apply, assoc_tmul, map_tmul, LinearMap.id_coe, id_eq,
      contrDual_symm', cast_cast, cast_eq, rid_tmul]
    rfl
  · simp only [map_add, add_tmul]
    rw [← h1, ← h2, tmul_add, LinearMap.map_add]

@[simp]
lemma unit_lid : (contrRightAux (𝓣.contrDual (𝓣.τ μ))) ((TensorProduct.comm R _ _) (𝓣.unit μ)
    ⊗ₜ[R] (𝓣.colorModuleCast (𝓣.τ_involutive μ).symm) x) = x := by
  have h1 := 𝓣.unit_rid μ x
  rw [← unit_lhs_eq]
  exact h1

/-!

## Properties of the metric

-/

variable [AddCommMonoid M] [AddCommMonoid N] [AddCommMonoid P] [AddCommMonoid Q] [AddCommMonoid S] [AddCommMonoid T] [Module R M] [Module R N] [Module R Q] [Module R S] [Module R T] [Module R P] in
@[simp] theorem _root_.TensorProduct.congr_refl_refl : TensorProduct.congr (.refl R M) (.refl R N) = .refl R _ :=
  LinearEquiv.toLinearMap_injective <| ext' fun _ _ ↦ rfl

@[simp]
lemma metric_cast (h : μ = ν) :
    (TensorProduct.congr (𝓣.colorModuleCast h) (𝓣.colorModuleCast h)) (𝓣.metric μ) =
    𝓣.metric ν := by
  subst h
  erw [congr_refl_refl]
  rfl

@[simp]
lemma metric_contrRight_unit (μ : 𝓣.Color) (x : 𝓣.ColorModule μ) :
    (contrRightAux (𝓣.contrDual μ)) (𝓣.metric μ ⊗ₜ[R]
    ((contrRightAux (𝓣.contrDual (𝓣.τ μ)))
      (𝓣.metric (𝓣.τ μ) ⊗ₜ[R] (𝓣.colorModuleCast (𝓣.τ_involutive μ).symm x)))) = x := by
  change (contrRightAux (𝓣.contrDual μ) ∘ₗ TensorProduct.map (LinearMap.id)
      (contrRightAux (𝓣.contrDual (𝓣.τ μ)))) (𝓣.metric μ
      ⊗ₜ[R] 𝓣.metric (𝓣.τ μ) ⊗ₜ[R] (𝓣.colorModuleCast (𝓣.τ_involutive μ).symm x)) = _
  rw [contrRightAux_comp]
  simp only [LinearMap.coe_comp, LinearEquiv.coe_coe, Function.comp_apply, assoc_symm_tmul,
    map_tmul, LinearMap.id_coe, id_eq]
  rw [𝓣.metric_dual]
  exact unit_lid 𝓣

/-!

## Dualizing

-/

/-- Takes a vector with index with dual color to a vector with index the underlying color.
  Obtained by contraction with the metric. -/
def dualizeSymm (μ : 𝓣.Color) : 𝓣.ColorModule (𝓣.τ μ) →ₗ[R] 𝓣.ColorModule μ :=
  contrRightAux (𝓣.contrDual μ) ∘ₗ
    TensorProduct.lTensorHomToHomLTensor R _ _ _ (𝓣.metric μ ⊗ₜ[R] LinearMap.id)

/-- Takes a vector to a vector with the dual color index.
  Obtained by contraction with the metric. -/
def dualizeFun (μ : 𝓣.Color) : 𝓣.ColorModule μ →ₗ[R] 𝓣.ColorModule (𝓣.τ μ) :=
  𝓣.dualizeSymm (𝓣.τ μ) ∘ₗ (𝓣.colorModuleCast (𝓣.τ_involutive μ).symm).toLinearMap

/-- Equivalence between the module with a color `μ` and the module with color
  `𝓣.τ μ` obtained by contraction with the metric. -/
def dualizeModule (μ : 𝓣.Color) : 𝓣.ColorModule μ ≃ₗ[R] 𝓣.ColorModule (𝓣.τ μ) := by
  refine LinearEquiv.ofLinear (𝓣.dualizeFun μ) (𝓣.dualizeSymm μ) ?_ ?_
  · apply LinearMap.ext
    intro x
    simp [dualizeFun, dualizeSymm, LinearMap.coe_comp, LinearEquiv.coe_coe,
      Function.comp_apply, lTensorHomToHomLTensor_apply, LinearMap.id_coe, id_eq,
      contrDual_symm_contrRightAux_apply_tmul, metric_cast]
  · apply LinearMap.ext
    intro x
    simp only [dualizeSymm, dualizeFun, LinearMap.coe_comp, LinearEquiv.coe_coe,
      Function.comp_apply, lTensorHomToHomLTensor_apply, LinearMap.id_coe, id_eq,
      metric_contrRight_unit]

section
variable [Semiring R] [Semiring R₂]
variable [AddCommMonoid M] [AddCommMonoid M₂]
variable {module_M : Module R M} {module_M₂ : Module R₂ M₂}
variable {σ₁₂ : R →+* R₂} {σ₂₁ : R₂ →+* R}
variable {re₁₂ : RingHomInvPair σ₁₂ σ₂₁} {re₂₁ : RingHomInvPair σ₂₁ σ₁₂}
variable (f : M →ₛₗ[σ₁₂] M₂) (g : M₂ →ₛₗ[σ₂₁] M)
@[simp]
theorem _root_.LinearEquiv.ofLinear_toLinearMap {h₁ h₂} : (LinearEquiv.ofLinear f g h₁ h₂ : M ≃ₛₗ[σ₁₂] M₂) = f := rfl
end

@[simp]
lemma dualizeModule_equivariant (g : G) :
    (𝓣.dualizeModule μ) ∘ₗ ((MulActionTensor.repColorModule μ) g) =
    (MulActionTensor.repColorModule (𝓣.τ μ) g) ∘ₗ (𝓣.dualizeModule μ) := by
  apply LinearMap.ext
  intro x
  simp only [dualizeModule, dualizeFun, dualizeSymm, LinearEquiv.ofLinear_toLinearMap,
    LinearMap.coe_comp, LinearEquiv.coe_coe, Function.comp_apply, colorModuleCast_equivariant_apply,
    lTensorHomToHomLTensor_apply, LinearMap.id_coe, id_eq]
  nth_rewrite 1 [← MulActionTensor.metric_inv (𝓣.τ μ) g]
  exact contrRightAux_contrDual_equivariant_tmul 𝓣 g (𝓣.metric (𝓣.τ μ))
      ((𝓣.colorModuleCast (dualizeFun.proof_3 𝓣 μ)) x)

@[simp]
lemma dualizeModule_equivariant_apply (g : G) (x : 𝓣.ColorModule μ) :
    (𝓣.dualizeModule μ) ((MulActionTensor.repColorModule μ) g x) =
    (MulActionTensor.repColorModule (𝓣.τ μ) g) (𝓣.dualizeModule μ x) := by
  trans ((𝓣.dualizeModule μ) ∘ₗ ((MulActionTensor.repColorModule μ) g)) x
  · rfl
  · rw [dualizeModule_equivariant]
    rfl

/-- Dualizes the color of all indicies of a tensor by contraction with the metric. -/
def dualizeAll : 𝓣.Tensor cX ≃ₗ[R] 𝓣.Tensor (𝓣.τ ∘ cX) := by
  refine LinearEquiv.ofLinear
    (PiTensorProduct.map (fun x => (𝓣.dualizeModule (cX x)).toLinearMap))
    (PiTensorProduct.map (fun x => (𝓣.dualizeModule (cX x)).symm.toLinearMap)) ?_ ?_
  all_goals
    apply LinearMap.ext
    refine fun x ↦ PiTensorProduct.induction_on' x ?_ (by
      intro a b hx a
      simp only [Function.comp_apply, map_add, hx, LinearMap.id_coe, id_eq, LinearMap.coe_comp]
      simp_all only [Function.comp_apply, LinearMap.coe_comp, LinearMap.id_coe, id_eq])
    intro rx fx
    simp only [Function.comp_apply, PiTensorProduct.tprodCoeff_eq_smul_tprod,
      map_smul, LinearMap.coe_comp, LinearMap.id_coe, id_eq]
    apply congrArg
    change (PiTensorProduct.map _)
      ((PiTensorProduct.map _) ((PiTensorProduct.tprod R) fx)) = _
    rw [PiTensorProduct.map_tprod, PiTensorProduct.map_tprod]
    apply congrArg
    simp
-- omit [Fintype X] [DecidableEq X]
@[simp]
lemma dualizeAll_equivariant (g : G) : (𝓣.dualizeAll.toLinearMap) ∘ₗ (@rep R _ G _ 𝓣 _ X cX g)
    = 𝓣.rep g ∘ₗ (𝓣.dualizeAll.toLinearMap) := by
  apply LinearMap.ext
  intro x
  simp only [dualizeAll, Function.comp_apply, LinearEquiv.ofLinear_toLinearMap, LinearMap.coe_comp]
  refine PiTensorProduct.induction_on' x ?_ (by
      intro a b hx a
      simp only [map_add, hx]
      simp_all only [Function.comp_apply, LinearMap.coe_comp, LinearMap.id_coe, id_eq])
  intro rx fx
  simp only [PiTensorProduct.tprodCoeff_eq_smul_tprod, map_smul, rep_tprod]
  apply congrArg
  change (PiTensorProduct.map _) ((PiTensorProduct.tprod R) _) =
    (𝓣.rep g) ((PiTensorProduct.map _) ((PiTensorProduct.tprod R) fx))
  rw [PiTensorProduct.map_tprod, PiTensorProduct.map_tprod]
  simp

-- omit [Fintype C] [DecidableEq C] [Fintype P] [DecidableEq P] in
lemma dualize_cond (e : C ⊕ P ≃ X) :
    cX = Sum.elim (cX ∘ e ∘ Sum.inl) (cX ∘ e ∘ Sum.inr) ∘ e.symm := by
  rw [Equiv.eq_comp_symm]
  funext x
  match x with
  | Sum.inl x => rfl
  | Sum.inr x => rfl

-- omit [Fintype C] [DecidableEq C] [Fintype P] [DecidableEq P] in
lemma dualize_cond' (e : C ⊕ P ≃ X) :
    Sum.elim (𝓣.τ ∘ cX ∘ ⇑e ∘ Sum.inl) (cX ∘ ⇑e ∘ Sum.inr) =
    (Sum.elim (𝓣.τ ∘ cX ∘ ⇑e ∘ Sum.inl) (cX ∘ ⇑e ∘ Sum.inr) ∘ ⇑e.symm) ∘ ⇑e := by
  funext x
  match x with
  | Sum.inl x => simp
  | Sum.inr x => simp

/-- Given an equivalence `C ⊕ P ≃ X` dualizes those indices of a tensor which correspond to
  `C` whilst leaving the indices `P` invariant. -/
def dualize (e : C ⊕ P ≃ X) : 𝓣.Tensor cX ≃ₗ[R] 𝓣.Tensor (cX.partDual e) :=
  𝓣.mapIso e.symm (𝓣.dualize_cond e) ≪≫ₗ
  (𝓣.tensoratorEquiv _ _).symm ≪≫ₗ
  TensorProduct.congr 𝓣.dualizeAll (LinearEquiv.refl _ _) ≪≫ₗ
  (𝓣.tensoratorEquiv _ _) ≪≫ₗ
  𝓣.mapIso e (𝓣.dualize_cond' e)

-- omit [Fintype C] [Fintype P] in
/-- Dualizing indices is equivariant with respect to the group action. This is the
  applied version of this statement. -/
@[simp]
lemma dualize_equivariant_apply (e : C ⊕ P ≃ X) (g : G) (x : 𝓣.Tensor cX) :
    𝓣.dualize e (g • x) = g • (𝓣.dualize e x) := by
  simp only [dualize, TensorProduct.congr, LinearEquiv.refl_toLinearMap, LinearEquiv.refl_symm,
    LinearEquiv.trans_apply, rep_mapIso_apply, rep_tensoratorEquiv_symm_apply,
    LinearEquiv.ofLinear_apply]
  rw [← LinearMap.comp_apply (TensorProduct.map _ _), ← TensorProduct.map_comp]
  simp only [dualizeAll_equivariant, LinearMap.id_comp]
  have h1 {M N A B C : Type} [AddCommMonoid M] [AddCommMonoid N] [AddCommMonoid A]
      [AddCommMonoid B] [AddCommMonoid C] [Module R M] [Module R N] [Module R A] [Module R B]
      [Module R C] (f : M →ₗ[R] N) (g : A →ₗ[R] B) (h : B →ₗ[R] C) : TensorProduct.map (h ∘ₗ g) f
      = TensorProduct.map h f ∘ₗ TensorProduct.map g (LinearMap.id) :=
    ext rfl
  rw [h1, LinearMap.coe_comp, Function.comp_apply]
  simp only [tensoratorEquiv_equivariant_apply, rep_mapIso_apply]

end TensorStructure

end
