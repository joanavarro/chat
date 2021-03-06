/****************************************************
				TABLE PROFILE
****************************************************/
if OBJECT_ID('proc_InsertProfile ') is not null
	drop procedure proc_InsertProfile
go

CREATE PROCEDURE proc_InsertProfile 
    @id int OUTPUT,
    @login varchar(100),
	@password varchar(100)
AS
BEGIN

	IF EXISTS(SELECT * FROM Profile WHERE login = @login)
		BEGIN
			RAISERROR('Error, el usuario ya existe en la db', 18, 1)
			RETURN
		END
	ELSE
		BEGIN
			insert into Profile(login,password)
			values (@login, @password)

			SELECT TOP 1 @id = p.id
			FROM Profile p
			ORDER BY p.id DESC
		END
END
GO

/*Admin user*/
insert into Profile
values('admin','admin','ADMIN')

/*
DECLARE @id_out int;
EXECUTE proc_InsertProfile @id_out OUTPUT, 'nico', 'nico'
select @id_out as id
*/

if OBJECT_ID('proc_SelectProfiles ')is not null
	drop procedure proc_SelectProfiles
go

CREATE PROCEDURE proc_SelectProfiles
AS
BEGIN
  
	SELECT * FROM Profile
END
GO

if OBJECT_ID('proc_SelectProfileById ')is not null
	drop procedure proc_SelectProfileById
go

CREATE PROCEDURE proc_SelectProfileById
 @id int
AS
BEGIN
  
	SELECT * FROM Profile p
	where p.id = @id
END
GO

if OBJECT_ID('proc_SelectProfileByLogin ')is not null
	drop procedure proc_SelectProfileByLogin
go

CREATE PROCEDURE proc_SelectProfileByLogin
 @login varchar(100)
AS
BEGIN
  
	SELECT * FROM Profile p
	where p.login = @login
	
END
GO

if OBJECT_ID('proc_SelectProfileByLoginAndPassword ')is not null
	drop procedure proc_SelectProfileByLoginAndPassword
go

CREATE PROCEDURE proc_SelectProfileByLoginAndPassword
 @login varchar(100),
 @password varchar(100)
AS
BEGIN
	select * from Profile p
			where p.login = @login
			and p.password = @password
	 
	declare @cant int = (select count(p.id) from Profile p
						where p.login = @login
						and p.password = @password)

	if(@cant > 0)
	begin
		--si existe el usuario, inserto un access_login
		declare @date datetime = getDate()
		insert into User_login(profile, date_time_of_access_start, date_time_of_access_end)
		select p.id, @date, null from Profile p
		where p.login = @login
		and p.password = @password
	end	
END
GO

if OBJECT_ID('proc_SelectParticipantsForRoom ')is not null
	drop procedure proc_SelectParticipantsForRoom
go

CREATE PROCEDURE proc_SelectParticipantsForRoom
 @room int
AS
BEGIN
    /*Selecciona los usuarios que accedieron a salas con end_date null*/
	select p.* from Profile p
	join (select u1.* from User_access u1
		join (select u.profile, max(u.datetime_of_access_start) max_start from User_access u
			where u.room = @room
			group by u.profile)t
		on u1.profile = t.profile
		and u1.datetime_of_access_start = t.max_start
		and u1.datetime_of_access_end is null)t2
	on p.id = t2.profile
	and p.type = 'USER'
END
GO	

if OBJECT_ID('proc_SelectActivesUsersLogin ')is not null
	drop procedure proc_SelectActivesUsersLogin
go

CREATE PROCEDURE proc_SelectActivesUsersLogin
AS
BEGIN
		/*selecciona los usuarios logueados con date_end null*/
		select p.* from Profile p 
		join (select u.* from User_login u
				join (select l.profile, max(l.date_time_of_access_start) max_start
					from User_login	l
					group by l.profile)t
				on u.profile = t.profile
				and u.date_time_of_access_start = t.max_start)t2
		on p.id = t2.profile
		where p.type = 'USER'
		and t2.date_time_of_access_end is null
END
GO

if OBJECT_ID('proc_SearchUsersLogin ')is not null
	drop procedure proc_SearchUsersLogin
go

CREATE PROCEDURE proc_SearchUsersLogin
(
 @string_search	varchar(255) = null
)
as
begin

  set @string_search = '%' + isnull(ltrim(rtrim(@string_search)), '') + '%' 

  /*busca los usuarios logueados con date_end null y coincidan con la palabra de busqueda*/
	select p.* from Profile p 
	join (select u.* from User_login u
			join (select l.profile, max(l.date_time_of_access_start) max_start
				from User_login	l
				group by l.profile)t
			on u.profile = t.profile
			and u.date_time_of_access_start = t.max_start)t2
	on p.id = t2.profile
	where p.type = 'USER'
	and t2.date_time_of_access_end is null
	and p.login like @string_search

END
GO

if OBJECT_ID('proc_SelectRejectedInvitationsByRoom ')is not null
	drop procedure proc_SelectRejectedInvitationsByRoom
go

CREATE PROCEDURE proc_SelectRejectedInvitationsByRoom
 @room int 
AS
BEGIN
	/*Selecciona los usuarios que rechazaron la invitacion a un determinado chat privado y ademas borra las invitaciones*/
	select p.* from Profile p
		join (select * from Invitation i
			where i.room = @room
			and i.state = 'rejected')t
		on p.id = t.receiver

	declare @cant int = (select count(i.id) from Invitation i
						where i.room = @room
						and i.state = 'rejected')

	if(@cant > 0)
	begin
		--delete invitations
		delete from Invitation
		where id in (select i.id from Invitation i
					where i.room = @room
					and i.state = 'rejected')
	end
END
GO

/****************************************************
				TABLE User_login
****************************************************/

if OBJECT_ID('proc_InsertUserLogin ')is not null
	drop procedure proc_InsertUserLogin
go

CREATE PROCEDURE proc_InsertUserLogin
 @id		int OUTPUT,
 @profile	int,
 @datetimeOfAccessStart	datetime,
 @datetimeOfAccessEnd	datetime
AS
BEGIN
  
	insert into User_login(profile, date_time_of_access_start, date_time_of_access_end)
	values (@profile, @datetimeOfAccessStart, @datetimeOfAccessEnd)

	SELECT TOP 1 @id = ul.id
	FROM User_login ul
	ORDER BY ul.id DESC

END
GO

/*
DECLARE @id_out int;
EXECUTE proc_InsertUserLogin @id_out OUTPUT, 1, '2000-10-26 10:37:31.723', null
select @id_out as id
*/

if OBJECT_ID('proc_SelectUserLoginById ')is not null
	drop procedure proc_SelectUserLoginById
go

CREATE PROCEDURE proc_SelectUserLoginById
 @id int
AS
BEGIN
  
	select * from User_login
	where id = @id
END
GO

if OBJECT_ID('proc_SelectUserLoginByProfile ')is not null
	drop procedure proc_SelectUserLoginByProfile
go

CREATE PROCEDURE proc_SelectUserLoginByProfile
 @profile int
AS
BEGIN
  
	select * from User_login
	where profile = @profile
END
GO

if OBJECT_ID('proc_SelectLastUserLogin ')is not null
	drop procedure proc_SelectLastUserLogin
go

CREATE PROCEDURE proc_SelectLastUserLogin
 @profile int
AS
BEGIN
	select * from User_login
	where date_time_of_access_start = (select max(date_time_of_access_start) 
									from User_login 
									where profile = @profile)

END
GO

if OBJECT_ID('proc_SelectUsersLogin ')is not null
	drop procedure proc_SelectUsersLogin
go

CREATE PROCEDURE proc_SelectUsersLogin
AS
BEGIN
		SELECT * FROM User_login
END
GO

if OBJECT_ID('proc_UpdateUserLogin ')is not null
	drop procedure proc_UpdateUserLogin
go

CREATE PROCEDURE proc_UpdateUserLogin
 @id		int,
 @profile	int,
 @datetimeOfAccessStart	datetime,
 @datetimeOfAccessEnd	datetime
AS
BEGIN
  
	UPDATE User_login
	set date_time_of_access_end = @datetimeOfAccessEnd
	where id = @id
END
GO

--exec proc_UpdateUserLogin 8,15, '2015-10-26 14:23:30.140', '2015-10-26 16:23:30.140'

/****************************************************
				TABLE Room
****************************************************/

if OBJECT_ID('proc_InsertRoom ')is not null
	drop procedure proc_InsertRoom
go

CREATE PROCEDURE proc_InsertRoom
 @id	int OUTPUT,
 @name	varchar(100),
 @type	varchar(100),
 @owner	int
AS
BEGIN
  
	insert into Room(name, type, owner)
	values (@name, @type, @owner)
		
	SELECT TOP 1 @id = id
	FROM Room
	ORDER BY id DESC

END
GO

/*
declare @id_out int
exec proc_InsertRoom @id_out OUTPUT,'ROOM1','TIPO1', null
select @id_out id
*/

if OBJECT_ID('proc_SelectRoomById ')is not null
	drop procedure proc_SelectRoomById
go

CREATE PROCEDURE proc_SelectRoomById
 @id int
AS
BEGIN
  
	select * from Room
	where id = @id
END
GO

if OBJECT_ID('proc_SelectRoomByName ')is not null
	drop procedure proc_SelectRoomByName
go

CREATE PROCEDURE proc_SelectRoomByName
 @name varchar(100)
AS
BEGIN
  
	select * from Room
	where name = @name
END
GO

if OBJECT_ID('proc_SelectRoomByOwner ')is not null
	drop procedure proc_SelectRoomByOwner
go

CREATE PROCEDURE proc_SelectRoomByOwner
 @owner int
AS
BEGIN
  
	select * from Room
	where owner = @owner
END
GO


/*
Select all rooms with user_cant column
**/
if OBJECT_ID('proc_SelectRooms ')is not null
	drop procedure proc_SelectRooms
go

CREATE PROCEDURE proc_SelectRooms
AS
BEGIN
	select *, (select count(u.id) cant_user
			from User_access u
			join (select profile, max(datetime_of_access_start) max_date_time
				from User_access
				where room = r.id
				group by profile)t
			on u.profile = t.profile
			and u.datetime_of_access_start = t.max_date_time
			and u.datetime_of_access_end is null
			join Profile p
			on p.id = u.profile
			and p.type = 'USER') cant_user
	from Room r
	where r.type = 'public'
END
GO

if OBJECT_ID('proc_SelectParticipantRoomsByProfile ')is not null
	drop procedure proc_SelectParticipantRoomsByProfile
go

CREATE PROCEDURE proc_SelectParticipantRoomsByProfile
 @profile int
AS
BEGIN
    /*selecciona las salas en las que participa un usuario*/
	select r.* from Room r
	join (select ul.* from User_access ul
		join (select u.room, max(u.datetime_of_access_start) max_start from User_access u
			where u.profile = @profile
			group by u.room)t
		on ul.room = t.room
		and ul.datetime_of_access_start = t.max_start)t2
	on r.id = t2.room
	and t2.datetime_of_access_end is null
	and r.type = 'public'
END
GO

if OBJECT_ID('proc_DeleteRoom ')is not null
	drop procedure proc_DeleteRoom
go

CREATE PROCEDURE proc_DeleteRoom
 @id int
AS
BEGIN
  
	delete Room
	where id = @id
END
GO

/****************************************************
				TABLE User_access
****************************************************/

if OBJECT_ID('proc_InsertUserAccess ')is not null
	drop procedure proc_InsertUserAccess
go

CREATE PROCEDURE proc_InsertUserAccess
 @id		int OUTPUT,
 @room		int,
 @profile	int,
 @datetimeOfAccessStart datetime,
 @datetimeOfAccessEnd datetime
AS
BEGIN
  
	insert into User_access(room, profile, datetime_of_access_start, datetime_of_access_end)
	values	(@room, @profile, @datetimeOfAccessStart, @datetimeOfAccessEnd)
		
	SELECT TOP 1 @id = id
	FROM User_access
	ORDER BY id DESC

END
GO

/*
declare @id_out int
exec proc_InsertUserAccess @id_out OUTPUT, 7, 1, '2015-10-26 00:00:00.000', null
select @id_out id
*/

if OBJECT_ID('proc_UpdateUserAccess')is not null
	drop procedure proc_UpdateUserAccess
go

CREATE PROCEDURE proc_UpdateUserAccess
 @id		int,
 @room		int,
 @profile	int,
 @datetimeOfAccessStart datetime,
 @datetimeOfAccessEnd datetime
AS
BEGIN
  
	update User_access
	set room = @room,
		profile = @profile,
		datetime_of_access_start = @datetimeOfAccessStart,
		datetime_of_access_end = @datetimeOfAccessEnd
	where id = @id
END
GO

if OBJECT_ID('proc_SelectUserAccessById ')is not null
	drop procedure proc_SelectUserAccessById
go

CREATE PROCEDURE proc_SelectUserAccessById
 @id int
AS
BEGIN
  
	select * from User_access
	where id = @id
END
GO

if OBJECT_ID('proc_SelectUserAccessByRoom ')is not null
	drop procedure proc_SelectUserAccessByRoom
go

CREATE PROCEDURE proc_SelectUserAccessByRoom
 @room int
AS
BEGIN
	select u.*
	from User_access u
	join (select profile, max(datetime_of_access_start) max_date_time
		from User_access
		where room = @room
		group by profile)t
	on u.profile = t.profile
	and u.datetime_of_access_start = t.max_date_time
	and u.datetime_of_access_end is null
	join Profile p
	on p.id = u.profile
	and p.type = 'USER'

END
GO

if OBJECT_ID('proc_SelectLastUserAccessByProfileAndRoom')is not null
	drop procedure proc_SelectLastUserAccessByProfileAndRoom
go

CREATE PROCEDURE proc_SelectLastUserAccessByProfileAndRoom
 @profile int,
 @room int
AS
BEGIN
	select * from User_access u
	where u.datetime_of_access_start = (select max(datetime_of_access_start) 
									from User_access
									where profile = @profile
									and room = @room)
END
GO

if OBJECT_ID('proc_SelectUsersAccess ')is not null
	drop procedure proc_SelectUsersAccess
go

CREATE PROCEDURE proc_SelectUsersAccess
AS
BEGIN
  
	select * from User_access
END
GO

/****************************************************
				TABLE Room_access_policy
****************************************************/

if OBJECT_ID('proc_InsertRoomAccessPolicy ')is not null
	drop procedure proc_InsertRoomAccessPolicy
go

CREATE PROCEDURE proc_InsertRoomAccessPolicy
 @id		int OUTPUT,
 @room		int,
 @profile	int,
 @policy	varchar(100)
AS
BEGIN
  
	insert into Room_access_policy(room, profile, policy)
	values	(@room, @profile, @policy)
		
	SELECT TOP 1 @id = id
	FROM Room_access_policy
	ORDER BY id DESC

END
GO

/*
declare @id_out int
exec proc_InsertRoomAccessPolicy @id_out OUTPUT, 1, 1, 'POLICY1'
select @id_out id
*/

if OBJECT_ID('proc_UpdateRoomAccessPolicy')is not null
	drop procedure proc_UpdateRoomAccessPolicy
go

CREATE PROCEDURE proc_UpdateRoomAccessPolicy
 @id		int,
 @room		int,
 @profile	int,
 @policy	varchar(100)
AS
BEGIN
  
	update Room_access_policy
	set room = @room,
		profile = @profile,
		policy = @policy
	where id = @id
END
GO

if OBJECT_ID('proc_SelectRoomAccessPolicyById ')is not null
	drop procedure proc_SelectRoomAccessPolicyById
go

CREATE PROCEDURE proc_SelectRoomAccessPolicyById
 @id int
AS
BEGIN
  
	select * from Room_access_policy
	where id = @id
END
GO

if OBJECT_ID('proc_SelectRoomAccessPolicyByRoom ')is not null
	drop procedure proc_SelectRoomAccessPolicyByRoom
go

CREATE PROCEDURE proc_SelectRoomAccessPolicyByRoom
 @room int
AS
BEGIN
  
	select * from Room_access_policy
	where room = @room
END
GO

if OBJECT_ID('proc_SelectRoomAccessPolicyByProfile ')is not null
	drop procedure proc_SelectRoomAccessPolicyByProfile
go

CREATE PROCEDURE proc_SelectRoomAccessPolicyByProfile
 @profile int
AS
BEGIN
 	select rap.*, p.login, r.name
	from Room_access_policy rap
	join Profile p on p.id = rap.profile
	join Room r on r.id = rap.room
	where rap.profile = @profile
	and rap.policy = 'enabled'

END
GO


if OBJECT_ID('proc_SelectAccessPolicyByRoomAndProfile ')is not null
	drop procedure proc_SelectAccessPolicyByRoomAndProfile
go

CREATE PROCEDURE proc_SelectAccessPolicyByRoomAndProfile
 @room int,
 @profile int
AS
BEGIN
  
	select * from Room_access_policy
	where id = (select max(id) from Room_access_policy
			where room = @room
			and profile = @profile)
END
GO

if OBJECT_ID('proc_SelectRoomsAccessPolicy ')is not null
	drop procedure proc_SelectRoomsAccessPolicy
go

CREATE PROCEDURE proc_SelectRoomsAccessPolicy
AS
BEGIN
  
	select rap.*, p.login, r.name
	from Room_access_policy rap
	join Profile p on p.id = rap.profile
	join Room r on r.id = rap.room
	and policy = 'ejected'
END
GO

if OBJECT_ID('proc_DeleteRoomsAccessPolicyByProfile ')is not null
	drop procedure proc_DeleteRoomsAccessPolicyByProfile
go

CREATE PROCEDURE proc_DeleteRoomsAccessPolicyByProfile
 @profile int
AS
BEGIN
  
	delete Room_access_policy 
	where profile = @profile
END
GO

if OBJECT_ID('proc_DeleteRoomsAccessPolicyByPolicyId ')is not null
	drop procedure proc_DeleteRoomsAccessPolicyByPolicyId
go

CREATE PROCEDURE proc_DeleteRoomsAccessPolicyByPolicyId
 @policy int
AS
BEGIN
  
	delete Room_access_policy 
	where id = @policy
END
GO

if OBJECT_ID('proc_UpdateRoomsAccessPolicyByPolicyId ')is not null
	drop procedure proc_UpdateRoomsAccessPolicyByPolicyId
go

CREATE PROCEDURE proc_UpdateRoomsAccessPolicyByPolicyId
 @policy int
AS
BEGIN
	update Room_access_policy
	set policy = 'enabled'
	where id = @policy
END
GO

/****************************************************
				TABLE Invitation
****************************************************/

if OBJECT_ID('proc_InsertInvitation ')is not null
	drop procedure proc_InsertInvitation
go

CREATE PROCEDURE proc_InsertInvitation
 @id		int OUTPUT,
 @room		int,
 @sender	int,
 @receiver	int,
 @state		varchar(100)
AS
BEGIN
  
	insert into Invitation(room, sender, receiver, state)
	values	(@room, @sender, @receiver, @state)
		
	SELECT TOP 1 @id = id
	FROM Invitation
	ORDER BY id DESC

END
GO

/*
declare @id_out int
exec proc_InsertInvitation @id_out OUTPUT, 1, 1, 2,'pending'
select @id_out id
*/

if OBJECT_ID('proc_UpdateInvitation')is not null
	drop procedure proc_UpdateInvitation
go

CREATE PROCEDURE proc_UpdateInvitation
 @id		int,
 @room		int,
 @sender	int,
 @receiver	int,
 @state		varchar(100)
AS
BEGIN
  
	update Invitation
	set room = @room,
		sender = @sender,
		receiver = @receiver,
		state = @state
	where id = @id
END
GO

if OBJECT_ID('proc_SelectInvitationById ')is not null
	drop procedure proc_SelectInvitationById
go

CREATE PROCEDURE proc_SelectInvitationById
 @id int
AS
BEGIN
  
	select * from Invitation
	where id = @id
END
GO

if OBJECT_ID('proc_SelectInvitationBySender ')is not null
	drop procedure proc_SelectInvitationBySender
go

CREATE PROCEDURE proc_SelectInvitationBySender
 @sender int
AS
BEGIN
  
	select * from Invitation
	where sender = @sender
END
GO

if OBJECT_ID('proc_SelectInvitationByReceiver ')is not null
	drop procedure proc_SelectInvitationByReceiver
go

CREATE PROCEDURE proc_SelectInvitationByReceiver
 @receiver int
AS
BEGIN
  
	select i.*, r.name as roomName, p.login as senderName
	from Invitation i
	join Room r on r.id = i.room
	join Profile p on p.id = i.sender
	where receiver = @receiver
	
END
GO

if OBJECT_ID('proc_SelectInvitations ')is not null
	drop procedure proc_SelectInvitations
go

CREATE PROCEDURE proc_SelectInvitations
AS
BEGIN
  
	select * from Invitation
END
GO

if OBJECT_ID('proc_DeleteInvitationsByProfile ')is not null
	drop procedure proc_DeleteInvitationsByProfile
go

CREATE PROCEDURE proc_DeleteInvitationsByProfile
 @profile int
AS
BEGIN
  
	delete Invitation
	where receiver = @profile
END
GO

if OBJECT_ID('proc_DeleteRejectedInvitationsByProfileAndRoom ')is not null
	drop procedure proc_DeleteRejectedInvitationsByProfileAndRoom
go

CREATE PROCEDURE proc_DeleteRejectedInvitationsByProfileAndRoom
 @profile int,
 @room int
AS
BEGIN
  
	delete Invitation
	where receiver = @profile
		and room = @room
		and state = 'rejected'
END
GO

if OBJECT_ID('proc_InviteParticipantToRoom ')is not null
	drop procedure proc_InviteParticipantToRoom
go

CREATE PROCEDURE proc_InviteParticipantToRoom
 @room int,
 @sender int,
 @login varchar(100)
AS
BEGIN
  
	 if exists(select * from Profile p where p.login = @login)
		 begin
			insert into Invitation(room, sender, receiver, state)
			select @room, @sender, p.id, 'pending'
			from Profile p
			where p.login = @login
		 end
	 else 
		 begin
			RAISERROR('Error, user not found', 16, 1)
			ROLLBACK
		 end
END
GO

/****************************************************
				TABLE Message
****************************************************/

if OBJECT_ID('proc_InsertMessage ')is not null
	drop procedure proc_InsertMessage
go

CREATE PROCEDURE proc_InsertMessage
 @id		int OUTPUT,
 @room		int,
 @owner		int,
 @datetimeOfCreation datetime,
 @body		varchar(100),
 @state		varchar(100)
AS
BEGIN
  
	insert into Message(room, owner, datetime_of_creation, body, state)
	values	(@room, @owner, @datetimeOfCreation, @body, @state)
		
	SELECT TOP 1 @id = id
	FROM Message
	ORDER BY id DESC

END
GO

/*
declare @id_out int
exec proc_InsertMessage @id_out OUTPUT, 7, 1, '2015-10-26 00:00:00.000', 'Three message', 'accepted'
select @id_out id
*/

if OBJECT_ID('proc_UpdateMessage')is not null
	drop procedure proc_UpdateMessage
go

CREATE PROCEDURE proc_UpdateMessage
 @id		int,
 @room		int,
 @owner		int,
 @datetimeOfCreation datetime,
 @body		varchar(100),
 @state		varchar(100)
AS
BEGIN
  
	update Message
	set room = @room,
		owner = @owner,
		datetime_of_creation = @datetimeOfCreation,
		body = @body,
		state = @state
	where id = @id
END
GO

if OBJECT_ID('proc_SelectMessageById ')is not null
	drop procedure proc_SelectMessageById
go

CREATE PROCEDURE proc_SelectMessageById
 @id int
AS
BEGIN
  
	select * from Message
	where id = @id
END
GO

if OBJECT_ID('proc_SelectMessageByRoom ')is not null
	drop procedure proc_SelectMessageByRoom
go

CREATE PROCEDURE proc_SelectMessageByRoom
 @room int
AS
BEGIN
  
	select * from Message
	where room = @room
END
GO

if OBJECT_ID('proc_SelectMessageByRoomAndProfile ')is not null
	drop procedure proc_SelectMessageByRoomAndProfile
go

CREATE PROCEDURE proc_SelectMessageByRoomAndProfile
 @room int,
 @profile int
AS
BEGIN
  
	declare @type varchar(10) = (select p.type from Profile p where id = @profile)

	if (@type = 'ADMIN')
		begin
			select msj.*, p.login
			from Profile p
			join (
			select * from Message m
			where m.room = @room
			and m.datetime_of_creation >= (select date_time_of_access_start from User_login --Last user login
											where date_time_of_access_start = (select max(date_time_of_access_start) 
																			from User_login 
																			where profile = @profile
																			and room = @room)))msj		
			on msj.owner = p.id
		end
	else
		begin
			select msj.*, p.login
			from Profile p
			join (select * from Message m
				where m.room = @room
				and m.datetime_of_creation >= (select u.datetime_of_access_start from User_access u --Last user access
											where u.datetime_of_access_start = (select max(datetime_of_access_start) 
											from User_access
											where profile = @profile
											and room = @room)))msj
			 on msj.owner = p.id
		end
END
GO

if OBJECT_ID('proc_SelectMessageByOwner ')is not null
	drop procedure proc_SelectMessageByOwner
go

CREATE PROCEDURE proc_SelectMessageByOwner
 @owner int
AS
BEGIN
  
	select * from Message
	where owner = @owner
END
GO

if OBJECT_ID('proc_SelectMessages ')is not null
	drop procedure proc_SelectMessages
go

CREATE PROCEDURE proc_SelectMessages
AS
BEGIN
  
	select * from Message
END
GO

if OBJECT_ID('proc_DeleteMessage ')is not null
	drop procedure proc_DeleteMessage
go

CREATE PROCEDURE proc_DeleteMessage
 @id int
AS
BEGIN
  
	delete from Message
	where id = @id
END
GO
