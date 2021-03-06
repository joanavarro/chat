<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Room</title>
        <!-- Bootstrap -->
        <link href="/chat/css/bootstrap.css" rel="stylesheet">
        <link href="/chat/css/jquery-ui.min.css" rel="stylesheet">
        <link href="/chat/css-chat/room.css" rel="stylesheet">
    </head>
    <body>
        <fmt:bundle basename="ar.edu.ubp.das.properties.etiquetas">
            <c:set value="${form.room}" var="room" ></c:set>
            <c:set value="${room.getName()}" var="roomName" ></c:set>
            <c:set value="${room.getType()}" var="roomType" ></c:set>
            <c:set value="${room.getOwner()}" var="roomOwner" ></c:set>
            <c:set value="${form.roomId}" var="roomId" ></c:set>
            <c:set value="${form.profile}" var="profile" ></c:set>           
            <c:set value="${profile.getLogin()}" var="profileLogin" ></c:set>
            <c:set value="${profile.getId()}" var="profileId" ></c:set>        
            <c:set value="${profile.getType()}" var="profileType" ></c:set>        
            <c:set value="${form.userAccess}" var="userAccess" ></c:set>
            <c:set value="${userAccess.getId()}" var="userAccessId" ></c:set>
            <c:set value="${form.accessDenied}" var="accessDenied" ></c:set>
            
            <input type="hidden" value="${roomId}" name="roomId" />
            <input type="hidden" value="${roomName}" name="roomName" />
            <input type="hidden" value="${roomType}" name="roomType" />
            <input type="hidden" value="${roomOwner}" name="roomOwner" />
            <input type="hidden" value="${profileId}" name="profileId" />
            <input type="hidden" value="${profileLogin}" name="profileLogin" />
            <input type="hidden" value="${profileType}" name="profileType" />
            <input type="hidden" value="${userAccessId}" name="userAccessId" />   
            
            <c:choose>
                <c:when test="${accessDenied != null}">
                    <div class="container-fluid">
                        <div class="row">
                            <div class="col-md-4">
                                <div class="btn-group btn-group-justified" role="group" aria-label="">
                                    <input type="hidden" value="${accessDenied}" name="accessDenied" />
                                    <a role="button" href="#" onclick="jsRoom.closeRoom('${roomId}'); return false;" ><fmt:message key="label_close" /></a>
                                    <h3><span class="label label-danger"><fmt:message key="label_access_denied" /></span></h3>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <!--Non Modal Alert-->
                    <div class="modal fade modeless" id="myModal" data-backdrop="false" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h4 class="modal-title" id="myModalLabel">Alert</h4>
                                </div>
                                <div class="modal-body"> <!--content here--> </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                                </div>
                            </div>
                        </div>
                    </div><!-- /.Non Modal Alert -->
                    
                    <nav class="navbar navbar-default navbar-fixed-top"> <%-- NavBar --%>
                        <div class="container">
                            <!-- Collect the nav links, forms, and other content for toggling -->
                            <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
                                <ul class="nav navbar-nav">
                                <c:choose>
                                    <c:when test="${roomType.equals('private')}" >
                                        <c:choose>
                                            <c:when test="${roomOwner == profileId}" >
                                                <li><a id="deletePrivateRoom" href="#" onclick="jsRoom.deletePrivateRoom(); return false;" ><fmt:message key="label_close" /></a></li>
                                            </c:when>
                                            <c:otherwise>
                                                <li><a id="leavePrivateRoom" href="#" onclick="jsRoom.leavePrivateRoom(); return false;" ><fmt:message key="label_leave" /></a></li>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        <li><a id="leavePrivateRoom" href="#" onclick="jsRoom.leavePrivateRoom(); return false;" ><fmt:message key="label_leave" /></a></li>
                                    </c:otherwise>
                                </c:choose>
                                </ul>
                            </div><!-- /.navbar-collapse -->
                        </div><!-- /.container-fluid -->
                    </nav> <%-- /.NavBar --%>
                    
                    <div class="container">
                        <div class="row">
                            
                            <div class="col-md-4 col-md-offset-4"><span class="label label-primary" id="response"></span></div>
                            
                            <div class="col-md-12"><h3><span class="label label-primary"><fmt:message key="label_room_name" /> ${roomName}</span></h3></div>
                            
                            <div class="col-md-8"> <%-- Left panel--%>
                                <div id="messages"></div> <%-- Messages --%>
                                <div class="panel-footer"> <%-- Enter message --%>
                                    <form id="sendMessage"> <%-- send message  --%>
                                        <div class="form-group">
                                            <div class="row">
                                                <div class="col-md-10">
                                                    <input type="text" class="form-control" name="message" placeholder="Enter message" required >
                                                </div>
                                                <div class="col-md-2">
                                                    <input class="form-control btn btn-info" name='send' type="submit" value="Send" />
                                                </div>
                                            </div>
                                        </div>
                                    </form> <%-- /send message  --%>
                                </div> <%-- /.Enter message --%>
                                
                                <div id="invitations" style="margin-top: 10px"></div> <%-- Invitations --%>
                            </div> <%-- /.Left panel--%>
                            
                            <div class="col-md-4"> <%-- Right panel --%>
                                <div class="row">
                                    
                                    <div class="col-md-12" id="participants"></div>   <%-- Participants in this room --%>
                                    <div class="col-md-12" id="ejectedParticipants"></div> <%-- All logued participants ejected --%>

                                    <c:choose>
                                        <c:when test="${roomType.equals('public')}">
                                            <div class="col-md-12"> <%-- New private chat --%>
                                                <div class="panel panel-primary">
                                                    <div class="panel-heading">
                                                        <fmt:message key="title_start_private_room" />                                                       
                                                    </div>
                                                    <form id="createPrivateRoom">
                                                        <div class="input-group" >
                                                            <input type="text" class="form-control" id="title" name="titleRoom" placeholder="I want to talk about..."
                                                                   autofocus="" required >
                                                            <input type="email" class="form-control" id="inviteEmail" name="inviteEmailRoom" placeholder="somebody@somewhere.com"
                                                                   required >
                                                            <input id="submit" class="form-control btn btn-primary btn-block" type="submit" value="Send" />
                                                        </div>
                                                    </form>
                                                </div>
                                            </div> <%-- /.New private chat --%>
                                        </c:when>
                                        <c:otherwise>
                                            <c:if test="${roomOwner.equals(profileId)}" >
                                                <div class="col-md-12"> <%--  --%>
                                                    <div class="panel panel-primary">
                                                        <div class="panel-heading">
                                                            <fmt:message key="label_invite_participant" />
                                                        </div>
                                                        <form id="inviteParticipant">
                                                            <div>
                                                                <input type="text" class="form-control" id="inviteEmail" name="inviteEmailRoom" 
                                                                       placeholder="somebody@somewhere.com" required >
                                                                <input id="submit" class="form-control btn btn-primary btn-block" type="submit" value="Send" >
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div> <%-- /.Invite participant --%>
                                            </c:if>
                                        </c:otherwise>
                                    </c:choose>
                                    
                                    <div class="col-md-12"> <%-- Alert message --%>
                                        <div class="alert " style="display: none" id="myAlert" role="alert"></div>
                                    </div> <%-- /.Alert message --%>
                                </div>
                            </div> <%-- /.Right panel --%>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </fmt:bundle>
                    
        <script lang="javascript" type="text/javascript" src="/chat/js/jquery.min.js"></script>  
        <script lang="javascript" type="text/javascript" src="/chat/js/jquery-ui.min.js"></script>    
        <script lang="javascript" type="text/javascript" src="/chat/js-chat/utils.js"></script>
        <script lang="javascript" type="text/javascript" src="/chat/js-chat/jsRoom.js"></script>  
        <script src="/chat/js/bootstrap.js"></script>
        
    </body>
</html>
