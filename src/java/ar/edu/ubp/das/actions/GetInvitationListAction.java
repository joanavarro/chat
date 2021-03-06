package ar.edu.ubp.das.actions;

import ar.edu.ubp.das.entities.InvitationComplexEntity;
import ar.edu.ubp.das.mvc.actions.Action;
import ar.edu.ubp.das.mvc.actions.DynaActionForm;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
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
public class GetInvitationListAction extends Action{

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        System.out.println("GetInvitationListAction:execute");
        
        String profileId = (String) this.getForm().getItem("profileId");
        String callFrom = (String) this.getForm().getItem("callFrom");
        
        Logger.getLogger(getClass().getName()).log(Level.INFO, "GetInvitationListAction-Param: {0}", profileId);
        Logger.getLogger(getClass().getName()).log(Level.INFO, "GetInvitationListAction-Param: {1}", callFrom);
        
        Client client = ClientBuilder.newClient();
 
        Logger.getLogger(getClass().getName()).log(Level.INFO, "GetInvitationListAction-PRE llamado a INVITATIONS");
        
        /**Get invitations*/
        Form form = new Form();
        form.param("id", profileId);
        WebTarget invitationTarget = client.target("http://localhost:8080/chat/webresources/invitations/receiver/id");        
        Invocation invitationInvocation = invitationTarget.request().buildPost(Entity.form(form));
        Response invitationResponse = invitationInvocation.invoke();
        
        Logger.getLogger(getClass().getName()).log(Level.INFO, "GetInvitationListAction-POS llamado a INVITATIONS: " + invitationResponse.getStatus());
       
        List<InvitationComplexEntity> invitationsList = invitationResponse.readEntity(new GenericType<List<InvitationComplexEntity>>(){});
        
        if(invitationsList != null){
            this.getForm().setItem("invitations", invitationsList);
            this.getForm().setItem("profileId", profileId);
            this.getForm().setItem("callFrom", callFrom);
            this.gotoPage("/template/user/invitationList.jsp", request, response);
        }
    }
    
}
