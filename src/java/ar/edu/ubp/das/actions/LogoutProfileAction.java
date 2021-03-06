package ar.edu.ubp.das.actions;

import ar.edu.ubp.das.entities.ProfileEntity;
import ar.edu.ubp.das.entities.UserLoginEntity;
import ar.edu.ubp.das.mvc.actions.Action;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
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
public class LogoutProfileAction extends Action{

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        System.out.println("LogoutProfileAction:execute");
        
        HttpSession session = request.getSession(false);
        
        if(session.getAttribute("profile") != null){
            ProfileEntity profile = (ProfileEntity) session.getAttribute("profile");
            String profileId = Integer.toString(profile.getId());
            
            Logger.getLogger(getClass().getName()).log(Level.INFO, "LogoutProfileAction-Param: {0}", profileId);
            
            Client client = ClientBuilder.newClient();
            
            Logger.getLogger(getClass().getName()).log(Level.INFO, "GetInvitationListAction-PRE llamado a POLICY");
            /**Delete all policys for profileId*/
            Form policyForm = new Form();
            policyForm.param("id", profileId);
            WebTarget policyTarget = client.target("http://localhost:8080/chat/webresources/roomaccesspolicy/delete/profile/id");        
            Invocation policyInvocation = policyTarget.request().buildPost(Entity.form(policyForm));
            Response policyResponse = policyInvocation.invoke();
            
            Logger.getLogger(getClass().getName()).log(Level.INFO, "GetInvitationListAction-POS llamado a POLICY: " + policyResponse.getStatus());
            Logger.getLogger(getClass().getName()).log(Level.INFO, "GetInvitationListAction-PRE llamado a INVITATION");
            /**Delete all invitations for profileId*/
            Form invitationForm = new Form();
            invitationForm.param("id", profileId);
            WebTarget invitationTarget = client.target("http://localhost:8080/chat/webresources/invitations/delete/profile/id");        
            Invocation invitationInvocation = invitationTarget.request().buildPost(Entity.form(invitationForm));
            Response invitationResponse = invitationInvocation.invoke();
            
            Logger.getLogger(getClass().getName()).log(Level.INFO, "GetInvitationListAction-POS llamado a INVITATION: "+invitationResponse.getStatus());
            Logger.getLogger(getClass().getName()).log(Level.INFO, "GetInvitationListAction-PRE llamado a USERLOGIN");
            
            /**Get lastlogin profile*/
            Form form = new Form();
            form.param("id", Integer.toString(profile.getId()));
            WebTarget userLoginTarget1 = client.target("http://localhost:8080/chat/webresources/userslogins/lastlogin/profile/id");        
            Invocation userLoginInvocation1 = userLoginTarget1.request().buildPost(Entity.form(form));
            Response userLoginResponse1 = userLoginInvocation1.invoke();
            
            Logger.getLogger(getClass().getName()).log(Level.INFO, "GetInvitationListAction-POS llamado a USERLOGIN: " +userLoginResponse1.getStatus());
            
            if(userLoginResponse1.getStatusInfo().getReasonPhrase().equals("OK")){
                UserLoginEntity userLogin = userLoginResponse1.readEntity(new GenericType<UserLoginEntity>(){});
                
                Logger.getLogger(getClass().getName()).log(Level.INFO, "GetInvitationListAction-PRE llamado a USERLOGINTERMINATE");
                
                /**User login terminate session*/
                WebTarget userLoginTarget2 = client.target("http://localhost:8080/chat/webresources/userslogins/id/terminate");        
                Invocation userLoginInvocation2 = userLoginTarget2.request().buildPut(Entity.json(userLogin));
                Response userLoginResponse2 = userLoginInvocation2.invoke();

                Logger.getLogger(getClass().getName()).log(Level.INFO, "GetInvitationListAction-POS llamado a USERLOGINTERMINATE: " + userLoginResponse2.getStatus());
                
                if(userLoginResponse2.getStatusInfo().getReasonPhrase().equals("OK")){
                    System.out.println("FinishSession:OK");
                    session.invalidate();
                }
            }
        }
        this.gotoPage("/template/login.jsp", request, response);
    }
    
}
