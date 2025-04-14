package de.elrebo.plugins;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;

import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.maven.plugins.annotations.Parameter;
import org.apache.maven.project.MavenProject;

/**
 * Validation of provided XML files in lifecycle phase validate:
 * The first part of the validation are consistency checks,
 * the second part are checks on Postgres specific limits.
 */
@Mojo(name = "validate-dv2gen", defaultPhase = LifecyclePhase.VALIDATE)
public class ValidateDv2Gen extends AbstractMojo {
    /**
     * The MavenProject using the plugin
     */
    @Parameter(defaultValue = "${project}", required = true, readonly = true)
    MavenProject project;

    @Override
    public void execute() throws MojoExecutionException, MojoFailureException {
        getLog().debug("ValidateDv2Gen.execute");
        try {
            transform("src/main/xml/RawVault.xml",
                    "xslt/validate/consistency_checks.xslt",
                    "target/temp/consistency_checks.xml");
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("src/main/xml/RawVault.xml",
                    "xslt/validate/pg_checks.xslt",
                    "target/temp/pg_checks.xml");
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }
    }

    private void transform(String xmlFile, String xsltFile, String outFile) throws TransformerException {
        getLog().debug("  transform " + xmlFile + " mit " + xsltFile + " nach " + outFile);
        TransformerFactory transformerFactory = TransformerFactory.newInstance();
        Source xsltSource = new StreamSource(this.getClass().getClassLoader().getResourceAsStream(xsltFile));
        Transformer transformer = transformerFactory.newTransformer(xsltSource);

        Source xmlSource = new StreamSource(xmlFile);
        Result result = new StreamResult(outFile);

        transformer.transform(xmlSource, result);
    }
}
