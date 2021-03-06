<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
    
<div>
    <fmt:bundle basename="ar.edu.ubp.das.properties.etiquetas">
        <c:set value="${form.publicRooms}" var="publicRooms" ></c:set>
        <c:set value="${form.profileId}" var="profileId" ></c:set>
        
        <c:choose>
            <c:when test="${publicRooms != null && !empty publicRooms}" >
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <fmt:message key="title_public_room"/>
                    </div>
                    <div class="panel-body">
                        <ul class="media-list">
                            <c:forEach items="${publicRooms}" var="room" varStatus="loop">
                                <li class="media">
                                    <div class="media-body">
                                        <div class="media">
                                            <a class="pull-left" href="#"><img class="media-object img-circle" src="/chat/img/room.png" /></a>
                                            <div class="media-body">
                                                <a href="#" onclick="jsHome.openPublicRoom('/chat/index.jsp?action=Room&roomId=${room.id}&profileId=${profileId}&roomName=${room.name}', '${room.name}', '${room.id}'); return false;" >${room.name}</a>
                                                <small class="text-muted"><p><fmt:message key="label_user_cant"/> ${room.cant_user}</p></small>
                                                <hr />
                                            </div>
                                        </div>
                                    </div>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <h4><fmt:message key="public_room_empty"/></h4>
            </c:otherwise>
        </c:choose>
    </fmt:bundle>
</div>

                                
                            