package com.thoughtworks.selenium.grid.examples.java;

import org.testng.annotations.Test;


/**
 */
public class PerigordTest extends GoogleImageTestBase {


    @Test(groups = {"example", "firefox", "default"}, description = "Lascaux Hall of the Bull")
    public void rubinius() throws Throwable {
        runScenario("Lascaux Hall of the Bull");
    }

    @Test(groups = {"example", "firefox", "default"}, description = "Sarlat")
    public void pontNeuf() throws Throwable {
        runScenario("Sarlat");
    }

    @Test(groups = {"example", "firefox", "default"}, description = "Cathedral in Perigueux")
    public void notreDameDeParis() throws Throwable {
        runScenario("Cathedral in Perigueux");
    }

    @Test(groups = {"example", "firefox", "default"}, description = "Montbazillac")
    public void versailles() throws Throwable {
        runScenario("Montbazillac");
    }

    @Test(groups = {"example", "firefox", "default"}, description = "Domme - La Halle Fleurie")
    public void domme() throws Throwable {
        runScenario("Domme - La Halle Fleurie");
    }

    @Test(groups = {"example", "firefox", "default"}, description = "Rouffignac")
    public void rouffignac() throws Throwable {
        runScenario("Rouffignac");
    }


}