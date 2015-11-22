package ar.edu.ubp.das.actions;

import ar.edu.ubp.das.entities.RoomAccessPolicyEntity;
import ar.edu.ubp.das.entities.RoomEntity;
import ar.edu.ubp.das.entities.UserAccessEntity;
import ar.edu.ubp.das.mvc.actions.Action;
import java.util.List;
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
public class RoomAction extends Action{

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        System.out.println("RoomAction:execute");
        
        String profileId = (String) this.getForm().getItem("profileId");
        String profileType = (String) this.getForm().getItem("profileType");
        String roomId = (String) this.getForm().getItem("roomId");
        
        Client client = ClientBuilder.newClient();
        
        /**Get policy for roomId*/
        Form form = new Form();
        form.param("id", roomId);
        WebTarget policyTarget = client.target("http://localhost:8080/chat/webresources/roomaccesspolicy/room/id");        
        Invocation policyInvocation = policyTarget.request().buildPost(Entity.form(form));
        Response policyResponse = policyInvocation.invoke();
        
        List<RoomAccessPolicyEntity> policyList = policyResponse.readEntity(new GenericType<List<RoomAccessPolicyEntity>>(){});
        
        boolean flag = false;
        
        /**Check if the user has been ejected for this room*/
        if(!policyList.isEmpty()){
            for (RoomAccessPolicyEntity policy : policyList) {
                if(policy.getProfile() == Integer.parseInt(profileId)){
                    flag = true;
                    break;
                }
            }
        }
        if(!flag){
            UserAccessEntity userAccess = new UserAccessEntity();
            userAccess.setProfile(Integer.parseInt(profileId));
            userAccess.setRoom(Integer.parseInt(roomId));

            /**Create useraccess*/
            WebTarget userAccessTarget = client.target("http://localhost:8080/chat/webresources/useraccess");        
            Invocation useraccessInvocation = userAccessTarget.request().buildPost(Entity.json(userAccess));
            Response res = useraccessInvocation.invoke();

            if(res.getStatus() != Response.Status.CONFLICT.getStatusCode()){
                userAccess = res.readEntity(new GenericType<UserAccessEntity>(){});
            }

            /**Get room*/
            WebTarget roomTarget = client.target("http://localhost:8080/chat/webresources/rooms/id");        
            Invocation roomInvocation = roomTarget.request().buildPost(Entity.form(form));
            Response roomResponse = roomInvocation.invoke();

            RoomEntity roomEntity = roomResponse.readEntity(new GenericType<RoomEntity>(){});

            this.getForm().setItem("profileId", profileId);
            this.getForm().setItem("profileType", profileType);
            this.getForm().setItem("roomId", roomId);
            this.getForm().setItem("roomName", roomEntity.getName());
            this.getForm().setItem("roomType", roomEntity.getType());
            this.getForm().setItem("userAccess", userAccess);
        }else{
            this.getForm().setItem("accessDenied", "true");
        }
        this.gotoPage("/template/user/room.jsp", request, response);        
    }
    
}
