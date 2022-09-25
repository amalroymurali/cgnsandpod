#include "fintrf.h"
C
C
C     A FORTRAN script to read a mat file and write it to CGNS format
C     Adapted from the matdemo.f file from MathWorks
C
C	Author: Amal Roy Murali
C	Organisation: Queen Mary University of London
C
C=====================================================================
C 
C
	program mat2cgns

C     Declarations
	use cgns
	use mod_write_cgns
      implicit none

      mwPointer matOpen, matGetDir, matGetNextVariable
      mwPointer matGetVariable, mxGetDoubles, mxGetSingles
      mwPointer matGetVariableInfo, matGetNextVariableInfo
      mwPointer mp, dir, adir(100), pa
      mwPointer mxGetM, mxGetN
      mwPointer i
      integer   matClose
      integer   stat, temp
      integer N_node, N_t, NGM, NGN
      mwSize    ndir
      character*32 names(100), name
      character*31 inputfile
      character*9 outputfile
      character*7 classname, mxGetClassName
      
      mwSize M
      parameter(M=32) 
	real*8 mxGetScalar
	
	mwSize nT, nX, nY, nZ, nP
	mwSize mxGetNumberOfElements
	real*8, allocatable:: X(:,:), Y(:,:), Z(:,:)
	real*8, allocatable:: T(:, :), P(:, :) 
	real*8 Rj


C
C-------------------------------------------------------------
C     Open file and read directory
C-------------------------------------------------------------
C
C	write(*,*) 'Enter input file name:'
C	read(*,*) inputfile
	call getarg(1, inputfile)
	write(*,*) 'input is', inputfile
	if (inputfile=='') then
		write(6,*) 'Input file not provided.'
		write(6,*) 'Type in shell: $ mat2cgns.exe inputfile'
		stop
	endif

	outputfile='SP7_test_'
	
	N_node=5100 !Total numnber of nodes
	N_t=10 ! Total number of time steps
	NGM=100 ! Number of rows in the mesh grid					!
	NGN=51 ! Number of columns in the mesh grid
	
	temp = index(inputfile, '.mat') - 1

      mp = matOpen(inputfile, 'r')
      if (mp .eq. 0) then
         write(6,*) 'Can''t open ', inputfile
         stop
      end if
C
C     Read directory
C
      dir = matGetDir(mp, temp)
      if (dir .eq. 0) then
         write(6,*) 'Can''t read directory.'
         stop
      endif
C
C     Copy pointer into an array of pointers
C
      ndir = temp
      call mxCopyPtrToPtrArray(dir, adir, ndir)
C
C     Copy pointer to character string
C
      do 20 i=1,ndir
         call mxCopyPtrToCharacter(adir(i), names(i), M)
   20 continue
C
      write(6,*) 'Directory of Mat-file:'
      do 30 i=1,ndir
         write(6,*) names(i)
   30 continue
C
      stat = matClose(mp)
      if (stat .ne. 0) then
         write(6,*) 'Error closing ', inputfile
         stop
      end if
C
C-------------------------------------------------------------
C     Reopen file and read full arrays
C-------------------------------------------------------------
C
      mp = matOpen(inputfile, 'r')
      if (mp .eq. 0) then
         write(6,*) 'Can''t open ', inputfile
         stop
      end if
C
C     Get Information on first array in mat file
C
      write(6,*) 'Getting Header info from first array.'
      pa = matGetVariableInfo(mp, names(1))
      nP = mxGetNumberOfElements(pa)
      write(6,*) 'Retrieved ', names(1)
      write(6,*) '  With size ', mxGetM(pa), '-by-', mxGetN(pa)
      call mxDestroyArray(pa)
      
      write(6,*) 'Getting Header info from next array.'
      pa = matGetNextVariableInfo(mp, name)
      nT = mxGetNumberOfElements(pa)
      write(6,*) 'Retrieved ', name
      write(6,*) '  With size ', mxGetM(pa), '-by-', mxGetN(pa)
      call mxDestroyArray(pa)

      write(6,*) 'Getting Header info from next array.'
      pa = matGetNextVariable(mp, name)
      nX = mxGetNumberOfElements(pa)
      write(6,*) 'Retrieved ', name
	  write(6,*) '  With size ', mxGetM(pa), '-by-', mxGetN(pa)
	  call mxDestroyArray(pa)

	  write(6,*) 'Getting Header info from next array.'
      pa = matGetNextVariable(mp, name)
      nY = mxGetNumberOfElements(pa)
      write(6,*) 'Retrieved ', name
	  write(6,*) '  With size ', mxGetM(pa), '-by-', mxGetN(pa)
	  call mxDestroyArray(pa)
C	Get P 
	  write(*,*) 'Extracting ', names(1), ' matrix'
      pa = matGetVariable(mp, names(1))
      write(6,*) ' size:', nP
      classname = mxGetClassName(pa)
	  write(*,*) 'Classname ', classname
      allocate(P(10, 5100))
C	Changing pointer to first data location
	  if (classname=="double") then
      	pa = mxGetDoubles(pa)
      	call mxCopyPtrToReal8(pa, P, nP)
      	write(6,*) ' size:', nP
      else
      	pa = mxGetSingles(pa)
      	call mxCopyPtrToReal4(pa, P, nP) 
      	write(6,*) ' size:', nP
      end if
      
      write(6,*) ' Sample', P(1:10,2)
	  write(6,*) ' Final shape of P', shape(P)
	  
C	Get T
	  write(*,*) 'Extracting ', names(2), ' matrix'
      pa = matGetVariable(mp, names(2))
      write(6,*) ' size:', nT
      classname = mxGetClassName(pa)
	  write(*,*) 'Classname ', classname
      allocate(T(nT, 1))
C	Changing pointer to first data location
	  if (classname=="double") then
      	pa = mxGetDoubles(pa)
      	call mxCopyPtrToReal8(pa, T, nT)
      	write(6,*) ' size:', nT
      else
      	pa = mxGetSingles(pa)
      	call mxCopyPtrToReal4(pa, T, nT) 
      	write(6,*) ' size:', nT
      end if
      
      write(6,*) ' Sample', T(1:10,1)
	  write(6,*) ' Final shape of T', shape(T)

C	  Get X
	  write(*,*) 'Extracting ', names(3), ' matrix'
      pa = matGetVariable(mp, names(3))
      write(6,*) ' size:', nX
      classname = mxGetClassName(pa)
C	Changing pointer to first data location
	  if (classname=="double") then
      	pa = mxGetDoubles(pa)
      	allocate(X(100, 51))
      	call mxCopyPtrToReal8(pa, X, nX)

      else
      	pa = mxGetSingles(pa)
      	allocate(X(100, 51))
      	call mxCopyPtrToReal4(pa, X, nX)
      end if
      write(6,*) ' Sample', X(1, 1:10)
      write(6,*) ' final shape of X', shape(X)

C	Get Y
	  write(*,*) 'Extracting ', names(4), ' matrix'
      pa = matGetVariable(mp, names(4))
C      write(6,*) 'pR=', pa
      write(6,*) ' size:', nY
      classname = mxGetClassName(pa)
C	Changing pointer to first data location
	  if (classname=="double") then
      	pa = mxGetDoubles(pa)
      	allocate(Y(100, 51))
      	call mxCopyPtrToReal8(pa, Y, nY)
      else
      	pa = mxGetSingles(pa)
      	allocate(Y(100, 51))
      	call mxCopyPtrToReal4(pa, Y, nY)
      end if
      write(6,*) ' Sample', Y(1,1:10)
	  write(6,*) ' Final shape of Y', shape(Y)

	  Z(:,:)=0.0
C	
	  write(6,*) 'Data reading successfull'
	  call write_cgns(X,Y,Z,T,P,N_t,outputfile)
c    	close(1)
      stop
      
      end
