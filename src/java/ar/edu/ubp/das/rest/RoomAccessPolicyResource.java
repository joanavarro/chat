/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ar.edu.ubp.das.rest;

import ar.edu.ubp.das.entities.RoomAccessPolicyComplexEntity;
import ar.edu.ubp.das.entities.RoomAccessPolicyEntity;
import ar.edu.ubp.das.mvc.actions.DynaActionForm;
import ar.edu.ubp.das.mvc.daos.Dao;
import ar.edu.ubp.das.mvc.daos.DaoFactory;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.UriInfo;
import javax.ws.rs.Produces;
import javax.ws.rs.Consumes;
import javax.ws.rs.FormParam;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.core.Response;

/**
 * REST Web Service
 *
 * @author Febo
 */
@Path("roomaccesspolicy")
public class RoomAccessPolicyResource {

    @Context
    private UriInfo context;

    /**
     * Creates a new instance of RoomAccessPolicyResource
     */
    public RoomAccessPolicyResource() {
    }

    @POST
    @Consumes("application/json")
    @Produces("application/json")
    public Response create(RoomAccessPolicyEntity entity){
        try {
            Dao dao = DaoFactory.getDao("RoomAccessPolicy");
            DynaActionForm form = new DynaActionForm();
            
            form.setItems(entity.toMap());
            dao.insert(form);
            entity.setId((int) form.getItem("id"));
            
            return Response.ok(entity).build();
        } catch (Exception ex) {
            Logger.getLogger(RoomAccessPolicyResource.class.getName()).log(Level.SEVERE, null, ex);
            return Response.serverError().build();
        }
    }
    
    /**no usado*/
    @POST
    @Path("find/id")
    @Produces("application/json")
    public Response findRoomAccessPolicyById(@FormParam("id") Integer id) {
        try {
            Dao dao = DaoFactory.getDao("RoomAccessPolicy");
            RoomAccessPolicyEntity entity = new RoomAccessPolicyEntity();
            DynaActionForm form = new DynaActionForm();
            List<DynaActionForm> resultSet;
            
            form.setItem("selector", "byId");
            form.setItem("id", id);
            resultSet = dao.select(form);
            
            if(resultSet.size() == 1){
                entity.fromMap(resultSet.get(0).getItems());
                return Response.ok(entity).build();
            } else{
                return Response.status(Response.Status.NOT_FOUND).build();
            }
        } catch (Exception ex) {
            Logger.getLogger(RoomAccessPolicyResource.class.getName()).log(Level.SEVERE, null, ex);
            return Response.serverError().build();
        }
    }
    
    @GET
    @Produces("application/json")
    public List<RoomAccessPolicyComplexEntity> findAll() {
        try {
            Dao dao = DaoFactory.getDao("RoomAccessPolicyComplex");
            DynaActionForm form = new DynaActionForm();
            List<DynaActionForm> resultSet;
            List<RoomAccessPolicyComplexEntity> entities = new LinkedList<>();
            
            form.setItem("selector", "findAll");
            resultSet = dao.select(form);
            
            for(DynaActionForm temp : resultSet ){
                RoomAccessPolicyComplexEntity e = new RoomAccessPolicyComplexEntity();
                e.fromMap(temp.getItems());
                entities.add(e);
            }
            
            return entities;
        } catch (Exception ex) {
            Logger.getLogger(RoomAccessPolicyResource.class.getName()).log(Level.SEVERE, null, ex);
            return null;
        }
    }
    
    @POST
    @Path("room/id")
    @Produces("application/json")
    public List<RoomAccessPolicyEntity> findRoomAccessPolicyByRoom(@FormParam("id") Integer id) {
        try {
            Dao dao = DaoFactory.getDao("RoomAccessPolicy");
            DynaActionForm form = new DynaActionForm();
            List<DynaActionForm> resultSet;
            List<RoomAccessPolicyEntity> entities = new LinkedList<>();
            
            form.setItem("selector", "byRoom");
            form.setItem("room", id);
            resultSet = dao.select(form);
            
            for(DynaActionForm temp : resultSet ){
                RoomAccessPolicyEntity e = new RoomAccessPolicyEntity();
                e.fromMap(temp.getItems());
                entities.add(e);
            }
            
            return entities;
        } catch (Exception ex) {
            Logger.getLogger(RoomAccessPolicyResource.class.getName()).log(Level.SEVERE, null, ex);
            return null;
        }
    }
    
    @POST
    @Path("room/id/profile/id")
    @Produces("application/json")
    public Response findAccessPolicyByRoomAndProfile(@FormParam("room") Integer room, @FormParam("profile") Integer profile) {
        try {
            Dao dao = DaoFactory.getDao("RoomAccessPolicy");
            DynaActionForm form = new DynaActionForm();
            List<DynaActionForm> resultSet;
            
            form.setItem("selector", "byRoomAndProfile");
            form.setItem("room", room);
            form.setItem("profile", profile);
            resultSet = dao.select(form);
            
            if(resultSet.size() == 1){
                return Response.ok().build();
            } else{
                return Response.status(Response.Status.NOT_FOUND).build();
            }
        } catch (Exception ex) {
            Logger.getLogger(RoomAccessPolicyResource.class.getName()).log(Level.SEVERE, null, ex);
            return Response.serverError().build();
        }
    }
    
    @POST
    @Path("delete/profile/id")
    @Produces("application/json")
    public Response deleteRoomAccessPolicy(@FormParam("id") Integer id){
        try {
            Dao dao = DaoFactory.getDao("RoomAccessPolicy");
            DynaActionForm form = new DynaActionForm();
            
            form.setItem("profile", id);
            dao.delete(form);
            
            return Response.ok().build();
        } catch (Exception ex) {
            Logger.getLogger(RoomAccessPolicyResource.class.getName()).log(Level.SEVERE, null, ex);
            return Response.serverError().build();
        }
    }
    
    @POST
    @Path("delete/policy/id")
    @Produces("application/json")
    public Response deleteRoomAccessPolicyByPolicyId(@FormParam("policyId") Integer policyId){
        try {
            Dao dao = DaoFactory.getDao("RoomAccessPolicyComplex");
            DynaActionForm form = new DynaActionForm();
            
            form.setItem("policyId", policyId);
            dao.delete(form);
            
            return Response.ok().build();
        } catch (Exception ex) {
            Logger.getLogger(RoomAccessPolicyResource.class.getName()).log(Level.SEVERE, null, ex);
            return Response.serverError().build();
        }
    }
    
    @POST
    @Path("update/policy/id")
    @Produces("application/json")
    public Response updateRoomAccessPolicyByPolicyId(@FormParam("policyId") Integer policyId){
        try {
            Dao dao = DaoFactory.getDao("RoomAccessPolicyComplex");
            DynaActionForm form = new DynaActionForm();
            
            form.setItem("policyId", policyId);
            dao.update(form);
            
            return Response.ok().build();
        } catch (Exception ex) {
            Logger.getLogger(RoomAccessPolicyResource.class.getName()).log(Level.SEVERE, null, ex);
            return Response.serverError().build();
        }
    }
    
    @POST
    @Path("enable/profile/id")
    @Produces("application/json")
    public List<RoomAccessPolicyComplexEntity> findEnableRoomAccessPolicyByProfile(@FormParam("profileId") Integer profileId) {
        try {
            Dao dao = DaoFactory.getDao("RoomAccessPolicyComplex");
            DynaActionForm form = new DynaActionForm();
            List<DynaActionForm> resultSet;
            List<RoomAccessPolicyComplexEntity> entities = new LinkedList<>();
            
            form.setItem("selector", "byProfile");
            form.setItem("profileId", profileId);
            resultSet = dao.select(form);
            
            for(DynaActionForm temp : resultSet ){
                RoomAccessPolicyComplexEntity e = new RoomAccessPolicyComplexEntity();
                e.fromMap(temp.getItems());
                entities.add(e);
            }
            
            return entities;
        } catch (Exception ex) {
            Logger.getLogger(RoomAccessPolicyResource.class.getName()).log(Level.SEVERE, null, ex);
            return null;
        }
    }

}
