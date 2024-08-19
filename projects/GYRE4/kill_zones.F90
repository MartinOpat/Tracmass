SUBROUTINE kill_zones
    !==========================================================================
    !
    ! Purpose
    ! -------
    !
    ! Adjusts the velocity of the particles to zero when they reach predefined
    ! boundary zones, effectively stopping their movement without killing them.
    !
    ! ==========================================================================
  
    USE mod_traj
    USE mod_domain
    USE mod_vel   ! Assuming this module includes the velocity variables
  
    IMPLICIT NONE
  
    INTEGER  :: nexit
  
    SELECT CASE(exitType)
  
    CASE(1)  ! Geographical boundaries
        DO nexit = 1, 10
           IF(ienw(nexit) <= x1 .AND. x1 <= iene(nexit) .AND. &
                jens(nexit) <= y1 .AND. y1 <= jenn(nexit) ) THEN
                uvel(x1, y1, :) = 0.0   ! Setting u velocity to zero
                vvel(x1, y1, :) = 0.0   ! Setting v velocity to zero
           END IF
        END DO
  
    CASE(2)  ! 

  
    CASE(3) ! 
  
    CASE(4)
        PRINT*, 'Hard coded limits of the domain with velocity zeroing'
  
    END SELECT
  
  END SUBROUTINE kill_zones
  