package ar.edu.ubp.das.rest;

import ar.edu.ubp.das.entities.InvitationEntity;
import ar.edu.ubp.das.mvc.actions.DynaActionForm;
import ar.edu.ubp.das.mvc.daos.Dao;
import ar.edu.ubp.das.mvc.daos.DaoFactory;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.UriInfo;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PUT;
import javax.ws.rs.core.Response;

/**
 * REST Web Service
 *
 * @author Febo
 */
@Path("invitations")
public class InvitationResource {

    @Context
    private UriInfo context;

    /**
     * Creates a new instance of InvitationsResource
     */
    public InvitationResource() {
    }

    @POST
    @Produces("application/json")
    @Consumes("application/json")
    public Response create(InvitationEntity entity){
        try {
            Dao dao = DaoFactory.getDao("Invitation");
            DynaActionForm form = new DynaActionForm();
            
            form.setItems(entity.toMap());
            dao.insert(form);
            entity.setId((Integer) form.getItem("id"));
            
            return Response.ok(entity).build();
        } catch (Exception ex) {
            Logger.getLogger(UserLoginResource.class.getName()).log(Level.SEVERE, null, ex);
            return Response.serverError().build();
        }
    }
    
    @PUT
    @Produces("application/json")
    @Consumes("application/json")
    public Response updateInvitation(InvitationEntity entity){
        try {
            Dao dao = DaoFactory.getDao("Invitation");
            DynaActionForm form = new DynaActionForm();
            
            form.setItems(entity.toMap());
            dao.update(form);
            
            return Response.ok(entity).build();
        } catch (Exception ex) {
            Logger.getLogger(InvitationResource.class.getName()).log(Level.SEVERE, null, ex);
            return Response.serverError().build();
        }
    }
    
    @GET
    @Produces("application/json")
    public List<InvitationEntity> findAll() {
        try {
            Dao dao = DaoFactory.getDao("Invitation");
            DynaActionForm form = new DynaActionForm();
            List<InvitationEntity> entities = new LinkedList<>();
            
            form.setItem("selector", "findAll");
            
            for(DynaActionForm temp : dao.select(form) ){
                InvitationEntity i = new InvitationEntity();
                i.fromMap(temp.getItems());
                entities.add(i);
            }
            
            return entities;
        } catch (Exception ex) {
            Logger.getLogger(InvitationResource.class.getName()).log(Level.SEVERE, null, ex);
            return null;
        }
    }
    
    @GET
    @Path("{id}")
    @Produces("application/json")
    public Response findById(@PathParam("id") Integer id) {
        try {
            Dao dao;
            DynaActionForm form;
            List<DynaActionForm> resultSet;
            
            dao = DaoFactory.getDao("Invitation");
            form = new DynaActionForm();
            form.setItem("selector", "byId");
            form.setItem("id", id);
            resultSet = dao.select(form);
            
            if(resultSet.size() == 1){
                InvitationEntity entity = new InvitationEntity(); 
                entity.fromMap(resultSet.get(0).getItems());
                return Response.ok(entity).build();
            }
            else {
                return Response.status(Response.Status.NOT_FOUND).build();
            }
        } catch (Exception ex) {
            Logger.getLogger(InvitationResource.class.getName()).log(Level.SEVERE, null, ex);
            return Response.serverError().build();
        }
    }
    
    @GET
    @Path("sender/{sender}")
    @Produces("application/json")
    public List<InvitationEntity> findInvitationBySender(@PathParam("sender") Integer sender) {
        try {
            Dao dao;
            DynaActionForm form;
            List<DynaActionForm> resultSet;
            List<InvitationEntity> entities = new LinkedList<>();
            
            dao = DaoFactory.getDao("Invitation");
            form = new DynaActionForm();
            form.setItem("selector", "bySender");
            form.setItem("sender", sender);
            resultSet = dao.select(form);
            
            for(DynaActionForm temp : resultSet ){
                InvitationEntity i = new InvitationEntity();
                i.fromMap(temp.getItems());
                entities.add(i);
            }
            
            return entities;
        } catch (Exception ex) {
            Logger.getLogger(InvitationResource.class.getName()).log(Level.SEVERE, null, ex);
            return null;
        }
    }
    
    @GET
    @Path("receiver/{receiver}")
    @Produces("application/json")
    public List<DynaActionForm> findInvitationByReceiver(@PathParam("receiver") Integer receiver) {
        String DB_DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
        String DB_CONNECTION = "jdbc:sqlserver://FEBO-PC\\MSSQLSERVER2012;databaseName=chat";
        String DB_USER = "desarrollador";
        String DB_PASSWORD = "intel123!";
        try {
            List<DynaActionForm> dynaFormList = new LinkedList<>();
            
            Class.forName( DB_DRIVER ) ;
            Connection conn = DriverManager.getConnection( DB_CONNECTION, DB_USER, DB_PASSWORD ) ;             
            CallableStatement cs = conn.prepareCall( "{call proc_SelectInvitationByReceiver(?)}" ) ;        
            cs.setInt( "receiver", receiver ) ;
            
            ResultSet rs = cs.executeQuery() ;
            while( rs.next() ){
                DynaActionForm f = new DynaActionForm();
                f.setItem("id", rs.getInt("id"));
                f.setItem("room", rs.getInt("room"));
                f.setItem("sender", rs.getInt("sender"));
                f.setItem("receiver", rs.getInt("receiver"));
                f.setItem("state", rs.getString("state"));
                f.setItem("roomName", rs.getString("roomName"));
                f.setItem("senderName", rs.getString("senderName")); 
                dynaFormList.add(f);
            }

            rs.close() ;
            cs.close() ;
            conn.close() ;

            return dynaFormList;
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(InvitationResource.class.getName()).log(Level.SEVERE, null, ex);
            return null;
        }
    }
    
    @GET
    @Path("receiver/{receiver}/invitationId/{invitationId}")
    @Produces("application/json")
    public List<DynaActionForm> findLastInvitationsById(@PathParam("receiver") Integer receiver, @PathParam("invitationId") Integer invitationId ) {
        String DB_DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
        String DB_CONNECTION = "jdbc:sqlserver://FEBO-PC\\MSSQLSERVER2012;databaseName=chat";
        String DB_USER = "desarrollador";
        String DB_PASSWORD = "intel123!";
        try {
            List<DynaActionForm> dynaFormList = new LinkedList<>();
            
            Class.forName( DB_DRIVER ) ;
            Connection conn = DriverManager.getConnection( DB_CONNECTION, DB_USER, DB_PASSWORD ) ;             
            CallableStatement cs = conn.prepareCall( "{call proc_SelectLastInvitations(?,?)}" ) ;        
            cs.setInt( "receiver", receiver ) ;
            cs.setInt( "invitationId", invitationId ) ;
            
            ResultSet rs = cs.executeQuery() ;
            
            while( rs.next() ){
                DynaActionForm f = new DynaActionForm();
                f.setItem("id", rs.getInt("id"));
                f.setItem("room", rs.getInt("room"));
                f.setItem("sender", rs.getInt("sender"));
                f.setItem("receiver", rs.getInt("receiver"));
                f.setItem("state", rs.getString("state"));
                f.setItem("roomName", rs.getString("roomName"));
                f.setItem("senderName", rs.getString("senderName")); 
                dynaFormList.add(f);
            }
            rs.close() ;
            cs.close() ;
            conn.close() ;

            return dynaFormList;
        } catch (Exception ex) {
            Logger.getLogger(InvitationResource.class.getName()).log(Level.SEVERE, null, ex);
            return null;
        }
    }
}
