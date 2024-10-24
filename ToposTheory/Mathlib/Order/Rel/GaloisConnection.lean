/-
Copyright (c) 2024 Lagrange Mathematics and Computing Research Center. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anthony Bordg
-/
import Mathlib.Data.Rel
import Mathlib.Order.GaloisConnection
import Mathlib.CategoryTheory.Limits.Shapes.Pullback.HasPullback
import ToposTheory.GrothendieckSubtopos
import ToposTheory.Saturation

/-!
# The Galois Connection Induced by a Relation

In this file, we show that an arbitrary relation `R` between a pair of types `α` and `β` defines
a pair `toDual ∘ R.leftDual` and `R.rightDual ∘ ofDual` of adjoint order-preserving maps between the
corresponding posets `Set α` and `(Set β)ᵒᵈ`.
We define `R.leftFixedPoints` (resp. `R.rightFixedPoints`) as the set of fixed points `J`
(resp. `I`) of `Set α` (resp. `Set β`) such that `rightDual (leftDual J) = J`
(resp. `leftDual (rightDual I) = I`).

## Main Results

⋆ `Rel.gc_leftDual_rightDual`: we prove that the maps `toDual ∘ R.leftDual` and
  `R.rightDual ∘ ofDual` form a Galois connection.
⋆ `Rel.equivFixedPoints`: we prove that the maps `R.leftDual` and `R.rightDual` induce inverse
  bijections between the sets of fixed points.

## References

⋆ Engendrement de topologies, démontrabilité et opérations sur les sous-topos, Olivia Caramello and
  Laurent Lafforgue (in preparation)

## Tags

relation, Galois connection, induced bijection, fixed points
-/

namespace Rel

variable {α β : Type*} (R : Rel α β)

/-! ### Pairs of adjoint maps defined by relations -/

open OrderDual

/-- `leftDual` maps any set `J` of elements of type `α` to the set `{b : β | ∀ a ∈ J, R a b}` of
elements `b` of type `β` such that `R a b` for every element `a` of `J`. -/
def leftDual (J : Set α) : Set β := {b : β | ∀ ⦃a⦄, a ∈ J → R a b}

/-- `rightDual` maps any set `I` of elements of type `β` to the set `{a : α | ∀ b ∈ I, R a b}`
of elements `a` of type `α` such that `R a b` for every element `b` of `I`. -/
def rightDual (I : Set β) : Set α := {a : α | ∀ ⦃b⦄, b ∈ I → R a b}

/-- The pair of functions `toDual ∘ leftDual` and `rightDual ∘ ofDual` forms a Galois connection. -/
theorem gc_leftDual_rightDual : GaloisConnection (toDual ∘ R.leftDual) (R.rightDual ∘ ofDual) :=
  fun J I ↦ ⟨fun h a ha b hb ↦ h (by simpa) ha, fun h b hb a ha ↦ h (by simpa) hb⟩

/-! ### Induced equivalences between fixed points -/

/-- `leftFixedPoints` is the set of elements `J : Set α` satisfying `rightDual (leftDual J) = J`. -/
def leftFixedPoints := {J : Set α | R.rightDual (R.leftDual J) = J}

/-- `rightFixedPoints` is the set of elements `I : Set β` satisfying `leftDual (rightDual I) = I`.
-/
def rightFixedPoints := {I : Set β | R.leftDual (R.rightDual I) = I}

open GaloisConnection

/-- `leftDual` maps every element `J` to `rightFixedPoints`. -/
theorem leftDual_mem_rightFixedPoint (J : Set α) : R.leftDual J ∈ R.rightFixedPoints := by
  apply le_antisymm
  · apply R.gc_leftDual_rightDual.monotone_l; exact R.gc_leftDual_rightDual.le_u_l J
  · exact R.gc_leftDual_rightDual.l_u_le (R.leftDual J)

/-- `rightDual` maps every element `I` to `leftFixedPoints`. -/
theorem rightDual_mem_leftFixedPoint (I : Set β) : R.rightDual I ∈ R.leftFixedPoints := by
  apply le_antisymm
  · apply R.gc_leftDual_rightDual.monotone_u; exact R.gc_leftDual_rightDual.l_u_le I
  · exact R.gc_leftDual_rightDual.le_u_l (R.rightDual I)

/-- The maps `leftDual` and `rightDual` induce inverse bijections between the sets of fixed points.
-/
def equivFixedPoints : R.leftFixedPoints ≃ R.rightFixedPoints where
  toFun := fun ⟨J, _⟩ => ⟨R.leftDual J, R.leftDual_mem_rightFixedPoint J⟩
  invFun := fun ⟨I, _⟩ => ⟨R.rightDual I, R.rightDual_mem_leftFixedPoint I⟩
  left_inv J := by obtain ⟨_, hJ⟩ := J; rw [Subtype.mk.injEq, hJ]
  right_inv I := by obtain ⟨_, hI⟩ := I; rw [Subtype.mk.injEq, hI]

theorem rightDual_leftDual_le_of_le {J J' : Set α} (h : J' ∈ R.leftFixedPoints) (h₁ : J ≤ J') :
    R.rightDual (R.leftDual J) ≤ J' := by
  rw [← h]
  apply R.gc_leftDual_rightDual.monotone_u
  apply R.gc_leftDual_rightDual.monotone_l
  exact h₁

theorem leftDual_rightDual_le_of_le {I I' : Set β} (h : I' ∈ R.rightFixedPoints) (h₁ : I ≤ I') :
    R.leftDual (R.rightDual I) ≤ I' := by
  rw [← h]
  apply R.gc_leftDual_rightDual.monotone_l
  apply R.gc_leftDual_rightDual.monotone_u
  exact h₁

end Rel

open CategoryTheory Opposite

namespace Subtopos

/-! ### The induced duality of topologies and subtoposes -/

universe u

variable {C : Type u} [SmallCategory C]

open Limits NatTrans Rel

def restrictionMap {X : C} (S : Sieve X) {X' : C} (f : X' ⟶ X) :
    (coyoneda.obj (op (yoneda.obj X'))) ⟶ (coyoneda.obj (op (S.pullback f).functor)) :=
  coyoneda.map (S.pullback f).functorInclusion.op

-- lemma restrictionMap_comp {X : C} {P : Cᵒᵖ ⥤ Type u}  {S : Sieve X} {Y Z : C} {g : Z ⟶ Y} (f : Y ⟶ X) :
--      restrictionMap P S (g ≫ f) = restrictionMap P (S.pullback f) g := sorry

def isIso_restrictionMap (XS : (X : C) × Sieve X) (P : Cᵒᵖ ⥤ Type u) : Prop :=
  ∀ {X' : C} (f : X' ⟶ XS.1), IsIso ((restrictionMap XS.2 f).app P)

theorem isIso_restrictionMap_iff_isSheafFor {X : C} (S : Sieve X) :
    (∀ {X' : C} (f : X' ⟶ X), Presieve.IsSheafFor P (S.pullback f).arrows) ↔ isIso_restrictionMap ⟨X, S⟩ P := by
  conv =>
    lhs
    ext X' f
    rw [Presieve.isSheafFor_iff_yonedaSheafCondition]
    unfold Presieve.YonedaSheafCondition
  conv =>
    rhs
    unfold isIso_restrictionMap
    simp [restrictionMap, isIso_iff_bijective, Function.bijective_iff_existsUnique]

theorem mem_leftFixedPoint (J : GrothendieckTopology C) :
    {⟨X, S⟩ : (X : C) × Sieve X | S ∈ J.sieves X} ∈ (leftFixedPoints isIso_restrictionMap) := by
  ext ⟨X, S⟩
  simp [leftFixedPoints, leftDual, rightDual]
  apply Iff.intro
  . rw [← Presheaf.sheaves_respect_iff_covering]
    intros h P hP
    have: (∀ {X' : C} (f : X' ⟶ X), Presieve.IsSheafFor P (S.pullback f).arrows) := by
      rw [isIso_restrictionMap_iff_isSheafFor]
      apply h
      intros YS hYS
      obtain ⟨Y, S'⟩ := YS
      rw [← isIso_restrictionMap_iff_isSheafFor]
      intros _ f
      exact hP.isSheafFor (S'.pullback f) (J.pullback_stable f hYS)
    have := this (𝟙 _)
    rw [Sieve.pullback_id] at this
    exact this
  . tauto

def yoneda_iso_top_functor (X : C) : yoneda.obj X ≅ Sieve.functor (X := X) ⊤ :=
  NatIso.ofComponents (fun X' ↦ by simp; exact Equiv.toIso {
    toFun := fun f ↦ ⟨f, trivial⟩
    invFun := fun g ↦ g.1
    left_inv := by tauto
    right_inv := by tauto
  })

lemma isIso_restrictionMap_top (X : C) (P : Cᵒᵖ ⥤ Type u) : isIso_restrictionMap ⟨X, ⊤⟩ P := by
  unfold isIso_restrictionMap restrictionMap
  intros X' f
  use (fun g ↦ by
    simp at g
    exact (yoneda_iso_top_functor X').hom ≫ g)
  aesop_cat

lemma isIso_restrictionMap_pullback {X : C} (S : Sieve X) (P : C ᵒᵖ ⥤ Type u)
    (h : isIso_restrictionMap ⟨X, S⟩ P) {Y : C} (f : Y ⟶ X) : isIso_restrictionMap ⟨Y, S.pullback f⟩ P := by
  unfold isIso_restrictionMap restrictionMap
  intros Z g
  rw [← Sieve.pullback_comp]
  exact h (g ≫ f)

--TODO(@doctorn) move this out
namespace Sieve

  def functorInclusion_of_pullback {X : C} (S : Sieve X) {Y : C} (f : Y ⟶ X) : (S.pullback f).functor ⟶ S.functor := by
    simp [Sieve.functor, Sieve.pullback]
    exact { app := fun Z ↦ fun ⟨g, hg⟩ ↦ ⟨g ≫ f, hg⟩ }

end Sieve

noncomputable def liftingOfTransitivity {X : C} (S R : Sieve X) (P : C ᵒᵖ ⥤ Type u)
    (hR : ∀ {Y : C} {f : Y ⟶ X}, S.arrows f → isIso_restrictionMap ⟨Y, R.pullback f⟩ P)
    (p : R.functor ⟶ P) : (S.functor ⟶ P) where
  app Z g := by
    obtain ⟨g, hg⟩ := g
    have := hR hg (𝟙 _)
    let i := Sieve.functorInclusion_of_pullback R g
    let l := inv ((restrictionMap (Sieve.pullback g R) (𝟙 _)).app P)
    simp at l
    exact (l (i ≫ p)).app Z (𝟙 _)
  naturality Z W f := sorry

lemma isIso_restrictionMap_transitive {X : C} (S R : Sieve X) (P : C ᵒᵖ ⥤ Type u)
    (hS : isIso_restrictionMap ⟨X, S⟩ P)
    (hR : ∀ {Y : C} {f : Y ⟶ X}, S.arrows f → isIso_restrictionMap ⟨Y, R.pullback f⟩ P) :
    isIso_restrictionMap ⟨X, R⟩ P := by
  unfold isIso_restrictionMap restrictionMap
  intros Y f
  unfold isIso_restrictionMap at hS

  have: ∀ {Z : C} {g : Z ⟶ Y}, (Sieve.pullback f S).arrows g
      → isIso_restrictionMap ⟨Z, Sieve.pullback g (Sieve.pullback f R)⟩ P := by
    intros Z g hg
    rw [← Sieve.pullback_comp]
    have: S.arrows (g ≫ f) := hg
    unfold isIso_restrictionMap
    intros W h
    exact hR this h

  use fun i ↦ inv (I := hS f) (liftingOfTransitivity (S.pullback f) (R.pullback f) P this i)
  sorry

instance instGrothendieckTopologyOfleftFixedPoint {J : Set ((X : C) × Sieve X)}
    (h : J ∈ leftFixedPoints isIso_restrictionMap) : GrothendieckTopology C := by
  simp [leftFixedPoints, rightDual, leftDual] at h
  apply GrothendieckTopology.mk (fun X ↦ {S : Sieve X | ⟨X, S⟩ ∈ J})
  . intros X
    rw [← h]
    intros P _
    exact isIso_restrictionMap_top X P
  . intros _ _ S f hS
    rw [← h]
    intros P hP
    exact isIso_restrictionMap_pullback S P (hP hS) f
  . intros _ S _ R _
    rw [← h]
    intros P _
    exact isIso_restrictionMap_transitive S R P (by tauto) (by tauto)

open GrothendieckTopos

variable {I : Set (Cᵒᵖ ⥤ Type u)}

theorem mem_rightFixedPoint (ℰ : Subtopos (Cᵒᵖ ⥤ Type u)) (h : ∀ P, ℰ.obj P ↔ P ∈ I) :
    I ∈ rightFixedPoints isIso_restrictionMap := by admit

instance subtopos_of_rightFixedPoint (h : I ∈ rightFixedPoints isIso_restrictionMap) :
    Subtopos (Cᵒᵖ ⥤ Type u) where
  obj P := P ∈ I
  adj := sorry
  flat := sorry
  mem := sorry

instance : GrothendieckTopology C ≃ Subtopos (Cᵒᵖ ⥤ Type u) := sorry

end Subtopos
