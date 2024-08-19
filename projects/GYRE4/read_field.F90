SUBROUTINE read_field

  !==========================================================================
  !
  ! Purpose
  ! -------
  !
  ! Read test model output to advect trajectories.
  ! Will be called by the loop each time step.
  !
  ! Method
  ! ------
  !
  ! Read velocities and optionally some tracers from netCDF files and
  ! update velocity fields for TRACMASS.
  !
  ! Updates the variables:
  !   uflux and vflux
  ! ==========================================================================


   USE mod_precdef
   USE mod_param
   USE mod_vel
   USE mod_time
   USE mod_grid
   USE mod_getfile
   USE mod_tracervars
   USE mod_tracers
   USE mod_calendar
   USE mod_swap

   USE netcdf

   IMPLICIT none

   INTEGER        :: kk, itrac

   REAL(DP), ALLOCATABLE, DIMENSION(:,:,:)  :: tmp3d
   CHARACTER (len=200)                      :: fieldFile, dateprefix

   ! Reassign the time index of uflux and vflux, dzt, dzdt, hs, ...
   CALL swap_time()

   ! Data files
   dateprefix = ' '

   ! Reading 3-time step variables
   ! In this case: hs and zstot
   ! ===========================================================================
  

   ! Reading 2-time step variables
   ! In this case: velocities and tracers
   ! ===========================================================================
   ALLOCATE(tmp3d(imt,jmt,km))

   nctstep = currMon
   IF (l_onestep) nctstep = 1

   dateprefix = filledFileName(dateFormat, currYear, currMon, currDay)

   fieldFile = TRIM(physDataDir)//TRIM(physPrefixForm)//TRIM(uGridName)//'_d'//TRIM(dateprefix)//TRIM(fileSuffix)
   uvel(1:imt,1:jmt,km:1:-1) = get3DfieldNC(fieldFile, ueul_name, [imindom,jmindom,1,nctstep],[imt,jmt,km,1],'st')

   fieldFile = TRIM(physDataDir)//TRIM(physPrefixForm)//TRIM(vGridName)//'_d'//TRIM(dateprefix)//TRIM(fileSuffix)
   vvel(1:imt,1:jmt,km:1:-1) = get3DfieldNC(fieldFile, veul_name,[imindom,jmindom,1,nctstep],[imt,jmt,km,1],'st')

  !  fieldFile = TRIM(physDataDir)//TRIM(physPrefixForm)//TRIM(wGridName)//'_d'//TRIM(dateprefix)//TRIM(fileSuffix)
  !  wvel(1:imt,1:jmt,km:1:-1) = get3DfieldNC(fieldFile, w_name,[imindom,jmindom,1,nctstep],[imt,jmt,km,1],'st')

   ! ===========================================================================

  ! Log the uvel and vvel to terminal to check that it is correct
  ! WRITE(*,*) 'uvel: ', SUM(uvel)
  ! WRITE(*,*) 'vvel: ', SUM(vvel)

  ! dyu and dzu and zstou logging
  ! WRITE(*,*) 'dzu: ', SUM(dzu)
  ! WRITE(*,*) 'zstou: ', SUM(zstou)

   ! uflux and vflux computation
   FORALL (kk = 1:km) uflux(:,:,kk,2)     = 75*uvel(:,:,kk)*dyu(:,:)*zstou(:,:)
   FORALL (kk = 1:km) vflux(:,1:jmt,kk,2) = 75*vvel(:,1:jmt,kk)*dxv(:,1:jmt)*zstov(:,:)

   !! Zero meridional flux at j=0 and j=jmt
   vflux(:,0  ,:,:) = 0.d0
   vflux(:,jmt,:,:) = 0.d0

   ! Log the flux to terminal to check that it is correct
  !  WRITE(*,*) 'uflux: ', SUM(uflux)
  !  WRITE(*,*) 'vflux: ', SUM(vflux)

   ! Reverse the sign of fluxes if trajectories are run backward in time.
   CALL swap_sign()


END SUBROUTINE read_field
