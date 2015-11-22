package ar.edu.ubp.das.actions;

import ar.edu.ubp.das.entities.ProfileEntity;
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
public class GetParticipantListAction extends Action{
    
    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        System.out.println("GetParticipantsListAction:execute");
        
        String roomId = (String) this.getForm().getItem("roomId");
        String profileType = (String) this.getForm().getItem("profileType");
        String userAccessId = (String) this.getForm().getItem("userAccessId");
        
        Client client = ClientBuilder.newClient();
        Form form = new Form();
        form.param("id", roomId);
        /**Get user actives in room*/
        WebTarget usersActivesTarget = client.target("http://localhost:8080/chat/webresources/profiles/room/id/actives");        
        Invocation usersActivesInvocation = usersActivesTarget.request().buildPost(Entity.form(form));
        Response usersActivesResponse = usersActivesInvocation.invoke();
        
        List<ProfileEntity> usersActivesList = usersActivesResponse.readEntity(new GenericType<List<ProfileEntity>>(){});       
        
        this.getForm().setItem("participantsList", usersActivesList);
        this.getForm().setItem("roomId", roomId);
        this.getForm().setItem("profileType", profileType);
        this.getForm().setItem("userAccessId", userAccessId);
        this.gotoPage("/template/user/participantList.jsp", request, response);
        
    }
    
}
