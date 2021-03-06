      IMPLICIT REAL*8 (A-H,O-Z)
      call sections
      stop
      end

      Subroutine  SECTIONS
      IMPLICIT REAL*8 (A-H,O-Z)
      real*8 AX(77777),AY(77777),AZ(77777),AT(77777)
      DIMENSION DX(0:40),DY(0:40),DZ(0:40)
C  This subroutine provides the values of consecutive
c  intersection coordinates of the solution of the Lorenz equations
c  with the plane Z=const      
c  (keeping them in the arrays AX and AY). Array DT contains the
c  time values at the moments of intersections.
c  These data are written into the file 'lorsec.dat'

      COMMON /ST/ DX,DY,DZ,Q,NO
      open(9,file='lorsec.dat',status='unknown',access='sequential',
     : form='formatted')
C  Introduce the parameters:
      P=10.d0
      B=8.d0/3.d0
      R=28.d0
C  Insert the initial point:
      write(*,"('  Initial X ? '$)")
      read*,x
      write(*,"('  Initial Y ? '$)")
      read*,y
      write(*,"('  Initial Z ? '$)")
      read*,z
      t=0
C  Insert the desired number of the Poincare sections
      write(*,"(' How many section points to find ? '$)")
      read*,JSECT
      isect=0
C  Insert the coordinate Z of the section plane
      write(*,"(' Coordinate Z of the secant plane = ? '$)")
      read*,zsect
  10  xp=x
      yp=y
      zp=z
      call step (P,R,B,X,Y,Z,DT)
      jjj=jjj+1
      T=T+DT
      IF(z.lt.zsect.and.zp.ge.zsect)then
C  computation of the section coordinates
	      td=0
	      tu=DT/q
   12         tt=td+0.5d0*(tu-td)
	      QZ=0.
       	      DO I=0,NO-1
	       QZ=(QZ+DZ(NO-I))*tt
              ENDDO
	      if(zp+QZ.gt.zsect)td=tt
	      if(zp+QZ.le.zsect)tU=tt
              if(tu-td.Gt.1.d-10*DT/Q)goto 12
	      QX=0.
	      QY=0.
       	      DO I=0,NO-1
	       QX=(QX+DX(NO-I))*tt
 	       QY=(QY+DY(NO-I))*tt
              ENDDO
	        isect=isect+1
	        ax(isect)=xp+qx
	        ay(isect)=yp+qy
	        at(isect)=T-DT+tt*Q
      write(9,'(i10,3f20.11)') isect,ax(isect),ay(isect),at(isect)
      if(jsect/20*(20*isect/jsect).eq.isect)
     : write(*,"(i3,'%'$)")100*isect/jsect
      ENDIF 
      if(isect.lt.jsect)goto 10
      print*,'ready' 
      close(9)
      return
      end

      subroutine step (P,R,B,X,Y,Z,DT)
c  This subroutine performs one integration step for the Lorenz
c  equations by integrating them with the method of order NO,
c  and relative error TO. Here P,R and B are the usual parameters
c  of the Lorenz equations. The input values of X,Y,Z are the current
c  values of the respective variables; as the output values they
c  contain the new values. The neccesary stepsize is computed
c  automatically and can be recovered from the output value DT.
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION DX(0:40),DY(0:40),DZ(0:40)
      COMMON /ST/ DX,DY,DZ,Q,NO
      DATA Q/1.d0/
      TO=1.D-17
      NO=25
      DX(0)=X
      DY(0)=Y
      DZ(0)=Z
      Q1=1.
      DO 19 ND=1,NO
         DXY=0
         DXZ=0
         ND1=ND-1
         QQ=Q/ND
         DO  I=0,ND1
            DXY=DXY+DX(I)*DY(ND1-I)
            DXZ=DXZ+DX(I)*DZ(ND1-I)
         enddo
         DX(ND)=P*(DY(ND1)-DX(ND1))*QQ
         DY(ND)=(R*DX(ND1)-DY(ND1)-DXZ)*QQ
         DZ(ND)=(DXY-B*DZ(ND1))*QQ
   13    Q1=1.
         Q2=DABS(DX(ND))+DABS(DY(ND))+DABS(DZ(ND))
         IF(Q2.LT.1.D-19)Q1=1.5
         IF(Q2.GT.1.D19)Q1=0.6
         IF(Q1.LT.0.95.OR.Q1.GT.1.05)THEN
	      Q2=Q1
	      DO  M=1,ND
	        DX(M)=DX(M)*Q2
	        DY(M)=DY(M)*Q2
	        DZ(M)=DZ(M)*Q2
	        Q2=Q2*Q1
	      enddo
	      Q=Q*Q1
	      GOTO 13
         ENDIF
   19 CONTINUE
      EX=DABS(DX(NO))/(DABS(X)+1.D-35)
      EY=DABS(DY(NO))/(DABS(Y)+1.D-35)
      EZ=DABS(DZ(NO))/(DABS(Z)+1.D-35)
      DT=(TO/DMAX1(EX,EY,EZ))**(1.d0/NO)
      QZ=0.
      QY=0.
      QX=0.
      DO I=0,NO-1
         QX=(QX+DX(NO-I))*DT
         QY=(QY+DY(NO-I))*DT
         QZ=(QZ+DZ(NO-I))*DT
      ENDDO
      X=X+QX
      Y=Y+QY
      Z=Z+QZ
      DT=DT*Q
      return
      END
