package ar.edu.ubp.das.actions;

import ar.edu.ubp.das.entities.RoomEntity;
import ar.edu.ubp.das.entities.UserAccessEntity;
import ar.edu.ubp.das.mvc.actions.Action;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.Invocation;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.Form;
import javax.ws.rs.core.GenericType;
import javax.ws.rs.core.Response;

/**
 *
 * @author Febo
 */
public class GetPublicRoomAction extends Action{

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        System.out.println("GetPublicRoomAction:execute");
        
        String profileId = (String) this.getForm().getItem("profileId");
        String profileType = (String) this.getForm().getItem("profileType");
        
        Client client = ClientBuilder.newClient();
        WebTarget publicRoomsTarget = client.target("http://localhost:8080/chat/webresources/rooms/type/public");        
        Invocation publicRoomsInvocation = publicRoomsTarget.request().buildGet();
        Response publicRoomsResponse = publicRoomsInvocation.invoke();
        List<RoomEntity> publicRoomsList = publicRoomsResponse.readEntity(new GenericType<List<RoomEntity>>(){});
        
        Map<RoomEntity,Integer> map = new LinkedHashMap<>();
        
        if(publicRoomsList != null){
            for(RoomEntity room : publicRoomsList) {
                Form form = new Form();
                form.param("id", room.getId().toString());
                WebTarget userAccessTarget = client.target("http://localhost:8080/chat/webresources/useraccess/room/id/actives");        
                Invocation userAccessInvocation = userAccessTarget.request().buildPost(Entity.form(form));
                Response userAccessResponse = userAccessInvocation.invoke();
                
                List<UserAccessEntity> userAccessList = userAccessResponse.readEntity(new GenericType<List<UserAccessEntity>>(){});
                
                map.put(room, userAccessList.size());
            }
            this.getForm().setItem("publicRooms", map);
            this.getForm().setItem("profileId", profileId);
            this.getForm().setItem("profileType", profileType);
            this.gotoPage("/template/user/publicRoomList.jsp", request, response);
        }else {
            response.getWriter().println("Empty public rooms");
        }
    }
    
}
