package de.elrebo.plugins;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;

import org.apache.commons.io.FileUtils;

import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.maven.plugins.annotations.Parameter;
import org.apache.maven.project.MavenProject;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Path;
import java.util.List;

/**
 * Generate DataVault files in lifecycle phase generate-resources
 * 1. The dbt model scripts in basedir/target/classes/DataVault/models/ and basedir/target/classes/DataVault/sql_scripts/ are created
 *    with XSLT transformations of the xml files in target/classes/DataVault/generated-sources/xml
 * 2. The batch scripts are copied from JAR resource DataVault/batch/ to basedir/target/classes/DataVault/batch/
 */
@Mojo(name = "generate-resources-dv2gen", defaultPhase = LifecyclePhase.GENERATE_RESOURCES)
public class GenerateResourcesDv2Gen extends AbstractMojo {
    @Parameter(defaultValue = "${project}", required = true, readonly = true)
    MavenProject project;

    @Override
    public void execute() throws MojoExecutionException, MojoFailureException {
        getLog().debug("GenerateResourcesDv2Gen.execute");
        String baseDir = String.valueOf(project.getBasedir());

        try {
            transform("target/classes/DataVault/generated-sources/xml/RawVault.xml",
                    "xslt/generate-resources/raw_vault_to_hub.xslt",
                    "target/temp/hub.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("target/classes/DataVault/generated-sources/xml/RawVault.xml",
                    "xslt/generate-resources/raw_vault_to_link.xslt",
                    "target/temp/link.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("target/classes/DataVault/generated-sources/xml/RawVault.xml",
                    "xslt/generate-resources/raw_vault_to_sat.xslt",
                    "target/temp/sat.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("target/classes/DataVault/generated-sources/xml/RawVault.xml",
                    "xslt/generate-resources/raw_vault_to_mas.xslt",
                    "target/temp/mas.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("target/classes/DataVault/generated-sources/xml/RawVault.xml",
                    "xslt/generate-resources/raw_vault_to_xts.xslt",
                    "target/temp/xts.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("target/classes/DataVault/generated-sources/xml/RawVault.xml",
                    "xslt/generate-resources/raw_vault_to_vlink.xslt",
                    "target/temp/vlink.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("target/classes/DataVault/generated-sources/xml/RawVault.xml",
                    "xslt/generate-resources/raw_vault_to_vsat.xslt",
                    "target/temp/vsat.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("target/classes/DataVault/generated-sources/xml/RawVault.xml",
                    "xslt/generate-resources/raw_vault_to_vmas.xslt",
                    "target/temp/vmas.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("target/classes/DataVault/generated-sources/xml/RawVault.xml",
                    "xslt/generate-resources/raw_vault_to_vxts.xslt",
                    "target/temp/vxts.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("target/classes/DataVault/generated-sources/xml/BusinessVault_2.xml",
                    "xslt/generate-resources/business_vault_to_as_of_date.xslt",
                    "target/temp/as_of_date.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("target/classes/DataVault/generated-sources/xml/BusinessVault_2.xml",
                    "xslt/generate-resources/business_vault_to_pit.xslt",
                    "target/temp/pit.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("target/classes/DataVault/generated-sources/xml/RawVault.xml",
                    "xslt/generate-resources/file_imports.xslt",
                    "target/temp/file_imports.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("target/classes/DataVault/generated-sources/xml/RawVault.xml",
                    "xslt/generate-resources/db_sources.xslt",
                    "target/temp/db_sources.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            transform("target/classes/DataVault/generated-sources/xml/RawVault.xml",
                    "xslt/generate-resources/stages.xslt",
                    "target/temp/stages.xml",
                    baseDir);
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }

        try {
            copyDataVaultScripts(baseDir);
        } catch (IOException e) {
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

    private void copyDataVaultScripts(String baseDir) throws IOException {
        getLog().debug("  copyBatchScripts, baseDir=" + baseDir);
        URL batchScripts = this.getClass().getClassLoader().getResource("DataVault/");
        getLog().debug(batchScripts.toString());

        FileResourcesUtils app = new FileResourcesUtils();

        // copy all files from JAR resource DataVault/batch to target/classes/DataVault/batch
        try {

            // get paths from DataVault/batch
            List<Path> result = app.getPathsFromResourceJAR("DataVault");
            for (Path path : result) {
                getLog().debug("Path : " + path);

                String filePathInJAR = path.toString();
                // Windows will returns /json/file1.json, cut the first /
                // the correct path should be json/file1.json
                if (filePathInJAR.startsWith("/")) {
                    filePathInJAR = filePathInJAR.substring(1, filePathInJAR.length());
                }

                getLog().debug("filePathInJAR : " + filePathInJAR);

                // read a file from resource folder
                InputStream is = app.getFileFromResourceAsStream(filePathInJAR);

                File targetFile = new File(baseDir + "/target/classes/" + filePathInJAR);

                FileUtils.copyInputStreamToFile(is, targetFile);
            }

        } catch (URISyntaxException | IOException e) {
            e.printStackTrace();
        }

    }
}
