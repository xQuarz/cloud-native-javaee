package de.qaware.oss.cloud.service.dashboard;

import org.eclipse.microprofile.opentracing.Traced;
import org.keycloak.KeycloakSecurityContext;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.servlet.http.HttpServletRequest;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.ws.rs.Consumes;
import javax.ws.rs.FormParam;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Level;
import java.util.logging.Logger;

@ApplicationScoped
@Path("gui")
public class GuiResource {

    @Inject
    private Logger logger;

    @Inject
    private ProcessServiceClient processService;

    @Inject
    HttpServletRequest request;

    @POST
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Traced(operationName = "POST send")
    public Response send(@FormParam("processId") @NotBlank String processId,
                         @FormParam("name") @NotBlank String name,
                         @FormParam("amount") @NotNull Long amount) {

        KeycloakSecurityContext keycloakSecurityContext = (KeycloakSecurityContext) request.getAttribute(KeycloakSecurityContext.class.getName());

        logger.log(Level.INFO, "Received form POST request ({0}, {1}, {2}, {3}).", new Object[]{processId, name, amount,
                keycloakSecurityContext.getIdToken().getName()});
        processService.send(processId, name, amount);
        return Response.noContent().build();
    }


}
