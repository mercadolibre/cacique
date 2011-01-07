package com.thoughtworks.selenium.grid.examples.java;

import org.testng.annotations.Test;


/**
 */
public class ParisTest extends GoogleImageTestBase {

    @Test(groups = {"example", "firefox", "default"}, description = "Louvre")
    public void louvre() throws Throwable {
        runScenario("Louvre");
    }

    @Test(groups = {"example", "firefox", "default"}, description = "Louvre")
    public void rubinius() throws Throwable {
        runScenario("Louvre");
    }

    @Test(groups = {"example", "firefox", "default"}, description = "Pont Neuf")
    public void pontNeuf() throws Throwable {
        runScenario("Pont Neuf");
    }

    @Test(groups = {"example", "firefox", "default"}, description = "Notre Dame de Paris")
    public void notreDameDeParis() throws Throwable {
        runScenario("Notre Dame de Paris");
    }

    @Test(groups = {"example", "firefox", "default"}, description = "Versailles")
    public void versailles() throws Throwable {
        runScenario("Versailles");
    }

    @Test(groups = {"example", "firefox", "default"}, description = "Seine by Night")
    public void seine() throws Throwable {
        runScenario("Seine by Night");
    }

    @Test(groups = {"example", "firefox", "default"}, description = "Tour Eiffel")
    public void tourEiffel() throws Throwable {
        runScenario("Tour Eiffel");
    }

    @Test(groups = {"example", "firefox", "default"}, description = "Avenue des Champs Elysees")
    public void champsElysees() throws Throwable {
        runScenario("Avenue des Champs Elysees");
    }

}