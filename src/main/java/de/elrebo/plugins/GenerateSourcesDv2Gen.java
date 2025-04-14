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
 * Generation of enhanced XML files in lifecycle phase generate-sources
 */
@Mojo(name = "generate-sources-dv2gen", defaultPhase = LifecyclePhase.GENERATE_SOURCES)
public class GenerateSourcesDv2Gen extends AbstractMojo {
    @Parameter(defaultValue = "${project}", required = true, readonly = true)
    MavenProject project;

    @Override
    public void execute() throws MojoExecutionException, MojoFailureException {
        getLog().debug("GenerateSourcesDv2Gen.execute");
        String baseDir = String.valueOf(project.getBasedir());
        try {
            transform("src/main/xml/RawVault.xml",
                    "xslt/generate-sources/generate_raw_vault.xslt",
                    "target/classes/DataVault/generated-sources/xml/RawVault.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("src/main/xml/BusinessVault.xml",
                    "xslt/generate-sources/generate_business_vault.xslt",
                    "target/classes/DataVault/generated-sources/xml/BusinessVault.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("target/classes/DataVault/generated-sources/xml/BusinessVault.xml",
                    "xslt/generate-sources/generate_business_vault_2.xslt",
                    "target/classes/DataVault/generated-sources/xml/BusinessVault_2.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }
    }

    private void transform(String xmlFile, String xsltFile, String outFile, String baseDir) throws TransformerException {
        getLog().debug("  transform " + xmlFile + " mit " + xsltFile + " nach " + outFile + ", baseDir=" + baseDir);
        TransformerFactory transformerFactory = TransformerFactory.newInstance();
        Source xsltSource = new StreamSource(this.getClass().getClassLoader().getResourceAsStream(xsltFile));
        Transformer transformer = transformerFactory.newTransformer(xsltSource);

        Source xmlSource = new StreamSource(xmlFile);
        Result result = new StreamResult(outFile);

        transformer.setParameter("baseDir", baseDir);
        transformer.transform(xmlSource, result);
    }
}

