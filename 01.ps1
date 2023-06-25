Configuration MyFirstConfiguration {
    Import-DscResource -ModuleName PsDesiredStateConfiguration
    Import-DscResource -Module xWebAdministration
    Import-DscResource -Module xPSDesiredStateConfiguration

    Node "localhost" {

        # Install the IIS role
        WindowsFeature IIS {
            Ensure = "Present"
            Name   = "Web-Server"
        }
       #Install ASP.NET 4.5
       WindowsFeature ASPNet45
       {
         Ensure = "Present"
         Name = "Web-Asp-Net45"
       }
        # Stop the default website
        xWebsite DefaultSite {
            Ensure       = "Present"
            Name         = "Default Web Site"
            State        = "Stopped"
            PhysicalPath = "C:\inetpub\wwwroot"
            DependsOn    = "[WindowsFeature]IIS"
        }

        # Download the website content
        $packageUri = "https://azdevst001.blob.core.windows.net/windows-powershell-dsc/CoolColorsWebsite.html"
        $packageOutFile = "C:\inetpub\CoolColorsWebsite\index.html"

        xRemoteFile FileDownload {
            Uri             = $packageUri
            DestinationPath = $packageOutFile
            DependsOn       = "[xWebsite]DefaultSite"
        }

        # Create a new website
        xWebsite SavTechWebSite {
            Ensure       = "Present"
            Name         = "CoolColorsWebsite"
            State        = "Started"
            PhysicalPath = "C:\inetpub\CoolColorsWebsite"
            DependsOn    = "[xRemoteFile]FileDownload"
        }
    }
}
