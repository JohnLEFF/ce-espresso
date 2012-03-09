!
! Copyright (C) 2003 PWSCF group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
!
!-----------------------------------------------------------------------
SUBROUTINE drhodv(nu_i)
  !-----------------------------------------------------------------------
  !
  !  calculate the electronic term <psi|dv|dpsi> of the dynamical matrix
  !
  USE pwcom
  USE cgcom
  USE mp_global,  ONLY : intra_pool_comm
  USE mp,         ONLY : mp_sum

  IMPLICIT NONE
  INTEGER :: nu_i
  !
  INTEGER :: nu_j, ibnd, kpoint
  real(DP) :: dynel(nmodes), work(nbnd)
  !
  CALL start_clock('drhodv')
  !
  dynel(:) = 0.d0
  kpoint = 1
  ! do kpoint=1,nks
  !
  !** calculate the dynamical matrix (<DeltaV*psi(ion)|\DeltaPsi(ion)>)
  !
  DO nu_j = 1,nmodes
     !
     ! DeltaV*psi(ion) for mode nu_j is recalculated
     !
     CALL dvpsi_kb(kpoint,nu_j)
     !
     !     this is the real part of <DeltaV*Psi(ion)|DeltaPsi(ion)>
     !
     CALL pw_dot('N',npw,nbnd,dvpsi,npwx,dpsi ,npwx,work)
     DO ibnd = 1,nbnd
        dynel(nu_j) = dynel(nu_j) + 2.0d0*wk(kpoint)*work(ibnd)
     ENDDO
  ENDDO
#ifdef __MPI
  CALL mp_sum( dynel, intra_pool_comm )
#endif
  !
  ! NB this must be done only at the end of the calculation!
  !
  DO nu_j = 1,nmodes
     dyn(nu_i,nu_j) = - (dyn(nu_i,nu_j)+dynel(nu_j))
  ENDDO
  !
  CALL stop_clock('drhodv')
  !
  RETURN
END SUBROUTINE drhodv
