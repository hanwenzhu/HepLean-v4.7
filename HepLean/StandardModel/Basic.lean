/-
Copyright (c) 2024 Joseph Tooby-Smith. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Tooby-Smith
-/
import Mathlib.Data.Complex.Exponential
import Mathlib.Geometry.Manifold.Instances.Real
import Mathlib.LinearAlgebra.Matrix.ToLin
import HepLean.Meta.Informal
/-!
# The Standard Model

This file defines the basic properties of the standard model in particle physics.

-/

namespace Matrix
section specialUnitaryGroup
variable (n) (α) [DecidableEq n] [Fintype n] [CommRing α] [StarRing α]
/--`Matrix.specialUnitaryGroup` is the group of unitary `n` by `n` matrices where the determinant
is 1. (This definition is only correct if 2 is invertible.)-/
abbrev specialUnitaryGroup := unitaryGroup n α ⊓ MonoidHom.mker detMonoidHom
variable {n} {α}
theorem mem_specialUnitaryGroup_iff :
    A ∈ specialUnitaryGroup n α ↔ A ∈ unitaryGroup n α ∧ A.det = 1 :=
  Iff.rfl
end specialUnitaryGroup
end Matrix

/-! TODO: Redefine the gauge group as a quotient of SU(3) x SU(2) x U(1) by a subgroup of ℤ₆. -/
universe v u
namespace StandardModel

open Manifold
open Matrix
open Complex
open ComplexConjugate

/-- The global gauge group of the Standard Model with no discrete quotients.
  The `I` in the Name is an indication of the statement that this has no discrete quotients. -/
abbrev GaugeGroupI : Type :=
  specialUnitaryGroup (Fin 3) ℂ × specialUnitaryGroup (Fin 2) ℂ × unitary ℂ

informal_definition gaugeGroupℤ₆SubGroup where
  physics :≈ "The subgroup of the un-quotiented gauge group which acts trivially on
    all particles in the standard model. "
  math :≈ "The ℤ₆-subgroup of ``GaugeGroupI with elements (α^2 * I₃, α^(-3) * I₂, α), where `α`
    is a sixth complex root of unity."
  ref :≈ "https://math.ucr.edu/home/baez/guts.pdf"
  deps :≈ [``GaugeGroupI]

informal_definition GaugeGroupℤ₆ where
  physics :≈ "The smallest possible gauge group of the Standard Model."
  math :≈ "The quotient of ``GaugeGroupI by the ℤ₆-subgroup `gaugeGroupℤ₆SubGroup`."
  ref :≈ "https://math.ucr.edu/home/baez/guts.pdf"
  deps :≈ [``GaugeGroupI, ``StandardModel.gaugeGroupℤ₆SubGroup]

informal_definition gaugeGroupℤ₂SubGroup where
  physics :≈ "The ℤ₂subgroup of the un-quotiented gauge group which acts trivially on
    all particles in the standard model. "
  math :≈ "The ℤ₂-subgroup of ``GaugeGroupI derived from the ℤ₂ subgroup of `gaugeGroupℤ₆SubGroup`."
  ref :≈ "https://math.ucr.edu/home/baez/guts.pdf"
  deps :≈ [``GaugeGroupI, ``StandardModel.gaugeGroupℤ₆SubGroup]

informal_definition GaugeGroupℤ₂ where
  physics :≈ "The guage group of the Standard Model with a ℤ₂ quotient."
  math :≈ "The quotient of ``GaugeGroupI by the ℤ₂-subgroup `gaugeGroupℤ₂SubGroup`."
  ref :≈ "https://math.ucr.edu/home/baez/guts.pdf"
  deps :≈ [``GaugeGroupI, ``StandardModel.gaugeGroupℤ₂SubGroup]

informal_definition gaugeGroupℤ₃SubGroup where
  physics :≈ "The ℤ₃-subgroup of the un-quotiented gauge group which acts trivially on
    all particles in the standard model. "
  math :≈ "The ℤ₃-subgroup of ``GaugeGroupI derived from the ℤ₃ subgroup of `gaugeGroupℤ₆SubGroup`."
  ref :≈ "https://math.ucr.edu/home/baez/guts.pdf"
  deps :≈ [``GaugeGroupI, ``StandardModel.gaugeGroupℤ₆SubGroup]

informal_definition GaugeGroupℤ₃ where
  physics :≈ "The guage group of the Standard Model with a ℤ₃-quotient."
  math :≈ "The quotient of ``GaugeGroupI by the ℤ₃-subgroup `gaugeGroupℤ₃SubGroup`."
  ref :≈ "https://math.ucr.edu/home/baez/guts.pdf"
  deps :≈ [``GaugeGroupI, ``StandardModel.gaugeGroupℤ₃SubGroup]

/-- Specifies the allowed quotients of `SU(3) x SU(2) x U(1)` which give a valid
  gauge group of the Standard Model. -/
inductive GaugeGroupQuot : Type
  | ℤ₆ : GaugeGroupQuot
  | ℤ₂ : GaugeGroupQuot
  | ℤ₃ : GaugeGroupQuot
  | I : GaugeGroupQuot

informal_definition GaugeGroup where
  physics :≈ "The (global) gauge group of the Standard Model given a choice of quotient."
  math :≈ "The map from `GaugeGroupQuot` to `Type` which gives the gauge group of the Standard Model
    for a given choice of quotient."
  ref :≈ "https://math.ucr.edu/home/baez/guts.pdf"
  deps :≈ [``GaugeGroupI, ``gaugeGroupℤ₆SubGroup, ``gaugeGroupℤ₂SubGroup, ``gaugeGroupℤ₃SubGroup,
    ``GaugeGroupQuot]

end StandardModel
