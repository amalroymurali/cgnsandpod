	module mod_write_cgns
	contains
	subroutine write_cgns(X,Y,Z,T,P,nsnap,fname)

	use cgns

	implicit none
	real(kind=8), allocatable    :: temp(:,:,:)
	real(kind=8), allocatable    :: time_S(:)
	real(kind=8)                 :: t0
	real(kind=8), intent(in)     :: T(:, :)
	real(kind=8), intent(in)     :: X(:, :), Y(:, :), Z(:, :)
	real(kind=8), intent(in)     :: P(:,:)  
C	real(kind=8), intent(in)     :: Vmag(:, :)
C	real(kind=8), intent(in)     :: V1(:, :)
C	real(kind=8), intent(in)     :: V2(:, :)
C	real(kind=8), intent(in)     :: V3(:, :)
	integer(kind=4), intent(in)  :: nsnap
	integer(kind=4)              :: n, l, ll
	integer(kind=4), parameter   :: nCharacters = 32
	character(len=nCharacters)   :: flowname
	character(len=nCharacters), allocatable :: flownameVector(:)
	character(len=50)            :: tempString
	character(len=1) 		     :: norm
	character(len=9), intent(in):: fname
	character(len=33)		     :: outfile
	
	integer(kind=4) :: index_node, index_grid, index_soln, index_field
	integer(kind=4) :: index_base, index_zone, index_flow, index_coord

	integer(kind=4) ier, nzones

	integer(kind=4), allocatable :: isize(:,:)

	character(len=16) :: zonename  

	character(len=30)  :: citer

	character(len=5)  :: cmode

	integer(kind=4) :: iFirstFlowSol

	index_soln = 1
	index_base = 1
	index_zone = 1
	nzones = 1
	write(*,*) achar(10) // '  Writing CGNS file ...'

	print *, 'Number of snapshots:', nsnap

	! Create time array

	allocate(flownameVector(nsnap))
	allocate(time_S(nsnap))

	time_S = T(1:nsnap,1)
	
	if (allocated(isize) .eqv. .false.) allocate(isize(2,2))
	do n = 1,nsnap
	time_S = T(n,1)
	write(outfile,'(A9,A6,I0.6,A5)') fname, "tstep_,",n,".cgns"
	print *, 'Writing ', outfile
	call cg_open_f(outfile,CG_MODE_WRITE,index_soln,ier)
	! Create a base
	call cg_base_write_f(index_soln,'Base',2,3, index_base,ier)
	if (ier .ne. CG_OK) call cg_error_exit_f

	isize(1,1)=size(X,1);
	isize(2,1)=size(X,2);
	isize(1,2)=isize(1,1)-1;  
	isize(2,2)=isize(2,1)-1;
	
	write(zonename,*) 'Zone_1'
	allocate(temp(isize(1,1),isize(2,1),1))

	! Create zone
	call cg_zone_write_f(index_soln,index_base,trim(zonename), 
     *	isize,Structured,index_zone,ier)
	if (ier .ne. CG_OK) call cg_error_exit_f
	
	! Save a flow for every timestep
C	do n = 1,nsnap
		write(flowname,'(A,I0.0)') 'FlowSolution_', n 
		flownameVector(n) = trim(flowname)
		
		call cg_sol_write_f(index_soln,index_base,index_zone,
     *     	trim(flowname),Vertex,index_flow,ier)
		if (ier .ne. CG_OK) call cg_error_exit_f


		! Vmag

		call cg_field_write_f(index_soln,index_base,index_zone,
     *		index_flow, RealDouble,
     *		'Pressure', P(n,:),index_field,ier)
		if (ier .ne. CG_OK) call cg_error_exit_f

		
C	end do
	
	call cg_ziter_write_f(index_soln,index_base, 1,
     *	'ZoneIterativeData',ier)
	if (ier .ne. CG_OK) call cg_error_exit_f

	call cg_goto_f(index_soln,index_base,ier,'Zone_t',1,
     *	'ZoneIterativeData_t',1,'end')
	if (ier .ne. CG_OK) call cg_error_exit_f
	write(6,*) flownameVector(n)
	call cg_array_write_f('FlowSolutionPointers',Character,2,
     *	(/ nCharacters, 1 /), trim(flowname), ier)
	if (ier .ne. CG_OK) call cg_error_exit_f
	
	! x-coordinate
	call cg_coord_write_f(index_soln,index_base,1, 
     *		RealDouble, 'CoordinateX',X,index_field,ier)
	if (ier .ne. CG_OK) call cg_error_exit_f

	! y-coordinate
	call cg_coord_write_f(index_soln,index_base,1, 
     *	     RealDouble,'CoordinateY',Y,index_field,ier)
	if (ier .ne. CG_OK) call cg_error_exit_f

	! z-coordinate
	call cg_coord_write_f(index_soln,index_base,1, 
     *	     RealDouble,'CoordinateZ',Z,index_field,ier)
	if (ier .ne. CG_OK) call cg_error_exit_f

	deallocate(temp)
      
	! Associate each flow solution to a timestep
	call cg_gopath_f(index_soln, '/Base', ier)
	if (ier .ne. CG_OK) call cg_error_exit_f

	call cg_biter_write_f(index_soln,index_base,
     *	'TimeIterValues',1,ier)
	if (ier .ne. CG_OK) call cg_error_exit_f

	call cg_goto_f(index_soln,index_base,ier,
     *	'BaseIterativeData_t',1,'end')
	if (ier .ne. CG_OK) call cg_error_exit_f

	call cg_array_write_f('TimeValues',RealDouble,1,1,time_S,ier)
	if (ier .ne. CG_OK) call cg_error_exit_f

	call cg_simulation_type_write_f(index_soln,index_base,
     *	TimeAccurate,ier)
	if (ier .ne. CG_OK) call cg_error_exit_f

	! Create descriptor so that the user may know 
	call cg_goto_f(index_soln,index_base,ier,'end')
	write(tempString,*) 'Jet flow data'
	call cg_descriptor_write_f('Additional info',trim(tempString),ier)
	if (ier .ne. CG_OK) call cg_error_exit_f

	call cg_close_f(index_soln,ier)
	if (ier .ne. CG_OK) call cg_error_exit_f

	end do
	end subroutine
	end module
