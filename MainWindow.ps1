using namespace System.Windows.Forms
using namespace System.ComponentModel
Add-Type -AssemblyName System.Windows.Forms
$errorProvider1 = [ErrorProvider]::new()

$styles = @{
    title = [System.Drawing.Font]::new("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Bold);
    body = [System.Drawing.Font]::new("Microsoft Sans Serif", 10)

};

Function Show-MainInterface {

    param(
        [hashtable]$Inputs,
        [switch]$Discovery,
        [switch]$InArchive,
        [string[]]$Defendant,
        [int]$CMSNumber
    );

    $main_form = New-Object System.Windows.Forms.Form
    $main_form.Text ='eDiscovery EDMS Uploader v3a'
    $main_form.Height = 640
    $main_form.Width = 480
    #$main_form.AutoSize = $true
    $main_form.Font = $styles.body

    $vloc = 10;
    $vspc = 25;
    $gwid = $main_form.Width-40;
    $iwid = $main_form.Width/2;
    $hloc = 10;
    $htab = [int]($main_form.Width/2.5);
    $gploc = 0;

    #------- File Destination
    $GroupBox1 = New-Object System.Windows.Forms.GroupBox;
    $GroupBox1.Location = New-Object System.Drawing.Point($hloc, $vloc);
    $GroupBox1.Text = "File Destination:";

    $Destination = [Ordered]@{
        'City Attorney CaseFile Archive' = 'eDisCityAtty'
        'Retained Counsel' = 'Retained';
        ' ' = '';
        'Primary Public Defender' = 'PrimaryDefender';
        'Alternate Public Defender' = 'AlternateDefender';
        'Office of Assigned Counsel' = 'AssignedCounsel';
        'Multiple Conflicts Counsel' = 'MultipleConflicts';
    };

    if ($Discovery -eq $false) {
        $Destination = $Destination[0];
    }
    $i = 0;
    $Destination.Keys | % {
        $gploc += $vspc;
        if ($_ -eq ' ') {
            return;
        }
        $RadioButton = New-Object System.Windows.Forms.RadioButton;
        $RadioButton.Text = $_;
        $RadioButton.Size = New-Object System.Drawing.Size(275, 17);
        $RadioButton.Font = $styles.body
        $RadioButton.Location = New-Object System.Drawing.Point($hloc, $gploc);
        $RadioButton.Name = $Destination[$_];
        $GroupBox1.Controls.Add($RadioButton)
    }
    $RadioButton = $GroupBox1.Controls.Find('eDisCityAtty', $false)[0]
    $RadioButton.Enabled = (-Not $InArchive)
    $RadioButton.Checked = (-Not $InArchive)

    $RadioButton = $GroupBox1.Controls.Find('Retained', $false)[0]
    $RadioButton.Enabled = $InArchive
    $RadioButton.Checked = $InArchive
   

    $gploc+=$vspc
    $GroupBox1.Size = New-Object System.Drawing.Size($gwid, $gploc);
    $GroupBox1.Font = $styles.title
    $main_form.Controls.Add($GroupBox1);
    $vloc+=$gploc;

    #------- Additional Options
    $vloc+=($vspc*1.25);
    $GroupBox2 = New-Object System.Windows.Forms.GroupBox;
    $GroupBox2.Location = New-Object System.Drawing.Point($hloc, $vloc);
    $GroupBox2.Text = "Additional Options:";

    $gploc = 0;
    @('Add Cover Sheet', 'Print Placeholder Sheet', 'Send Photograph Summary') | % {
        $gploc += $vspc;
        if ($_ -eq '') {
            return;
        }

        $CheckBox = New-Object System.Windows.Forms.CheckBox;
        $CheckBox.Text = $_;
        $CheckBox.Size = New-Object System.Drawing.Size(275, 17);
        $CheckBox.Font = $styles.body
        $CheckBox.Location = New-Object System.Drawing.Point($hloc, $gploc);
        $GroupBox2.Controls.Add($CheckBox)
    }
    $gploc += $vspc;
    $GroupBox2.Size = New-Object System.Drawing.Size($gwid, $gploc);
    $GroupBox2.Font = $styles.title
    $main_form.Controls.Add($GroupBox2);
    $vloc+=$gploc;

    #------- CMS Case Number
    $vloc+=($vspc*1.25);
    $LabelCN = New-Object System.Windows.Forms.Label
    $LabelCN.Text = "CMS Case Number"
    $LabelCN.Location  = New-Object System.Drawing.Point($hloc,$vloc)
    $LabelCN.AutoSize = $true
    $LabelCN.Enabled = (-not $InArchive);
    $main_form.Controls.Add($LabelCN)

    $TextCN = New-Object System.Windows.Forms.TextBox #MaskedTextBox
    #$TextCN.Mask = '0000009'
    $TextCN.Location  = New-Object System.Drawing.Point($htab, $vloc)
    $TextCN.Size = New-Object System.Drawing.Size(75, 17);
    if ($CMSNumber) {
        $TextCN.Text = $CMSNumber;
    }
    $TextCN.Enabled = (-not $InArchive);
    $TextCN.Add_Validating({
        param([object]$sender, [CancelEventArgs]$e)
       
        if ($TextCN.Text -match '[0-9]{6,8}') {
            $errorProvider1.SetError($TextCN, "")
        } else {
            $errorProvider1.SetError($TextCN, "Not a valid case number.")
        }
    })

    $main_form.Controls.Add($TextCN)

    #------- Defendant
    $vloc+=($vspc*1.25);
    $LabelDN = New-Object System.Windows.Forms.Label
    $LabelDN.Text = "Defendant"
    $LabelDN.Location  = New-Object System.Drawing.Point($hloc,$vloc)
    $LabelDN.AutoSize = $true
    $main_form.Controls.Add($LabelDN)

    $DropDownDN = New-Object System.Windows.Forms.ComboBox
    if ($Defendant -eq $null) {
        $Defendant = @(".Default") #".Dis"
    }
    $Defendant | % {
        $view = $_.Split(".")[0];
        $obj = [pscustomobject]@{View = $view; Value = $_};
        $DropDownDN.Items.Add($obj);
    }            
    $DropDownDN.DisplayMember = 'View';
    $DropDownDN.ValueMember   = 'Value';

    $DropDownDN.Location  = New-Object System.Drawing.Point($htab, $vloc)
    $DropDownDN.Width = $iwid
    $DropDownDN.AutoCompleteMode = 'Append'
    $DropDownDN.DropDownStyle = 'DropDownList'
    $main_form.Controls.Add($DropDownDN)

    #------- Type of File
    $vloc+=($vspc*1.25);
    $LabelTF = New-Object System.Windows.Forms.Label
    $LabelTF.Text = "Type of File"
    $LabelTF.Location  = New-Object System.Drawing.Point($hloc,$vloc)
    $LabelTF.AutoSize = $true
    $main_form.Controls.Add($LabelTF)

    $DropDownFT = New-Object System.Windows.Forms.ComboBox
    $Destination = [Ordered]@{
        'Default' = ".Dis";
        'Agency Reports-Right Side' = 'RTS';
        'RAPS' = 'RAP';
        'Agency Reports-Left Side' = 'LTS';
        'DCA Working File (editable)' = 'CAW';
        'CRE (DCA)' = 'CRV';
        'Transcripts' = 'TRN';
        'Motions' = 'MOT';
        ' ' = '';
        'Confidential Informant' = 'CII';
        'Correspondence' = 'COR'; 
        'Victim Forms/Receipts' = 'VIC';
        'Court Filings' = 'COM';
        'Private Atty Share' = 'PAS';
        'Other' = 'OTH';
        '--- FOR OLD CASES ONLY! ---' = '';
        'Left Side-Confidential' = 'CNF'; 
        'Left Side-Needs Review/Redaction' = 'URD';
        'RAPS ' = 'RPS'
    }
    #$DropDownFT.Items.AddRange($Destination.Keys)
    $Destination.Keys | % {
        $obj = [pscustomobject]@{View = $_; Value = $Destination[$_]}
        $DropDownFT.Items.Add($obj);
    }            
    $DropDownFT.DisplayMember = 'View';
    $DropDownFT.ValueMember   = 'Value';
    $DropDownFT.SelectedIndex = 0
    $DropDownFT.Location  = New-Object System.Drawing.Point($htab, $vloc)
    $DropDownFT.Width = $iwid
    $DropDownFT.AutoCompleteMode = 'Append'
    $DropDownFT.DropDownStyle = 'DropDownList'
    $DropDownFT.Add_Validating({
        param([object]$sender, [CancelEventArgs]$e);

        if ($DropDownFT.SelectedItem.Value -ne '') {
            $errorProvider1.SetError($DropDownFT, "")
        } else {
            $errorProvider1.SetError($DropDownFT, "Not a valid selection.")
        }
    })

    $main_form.Controls.Add($DropDownFT)

    #------- Submit Button
    $vloc+=($vspc*2);
    $ButtonSF = New-Object System.Windows.Forms.Button
    $ButtonSF.Location = New-Object System.Drawing.Size($htab,$vloc)
    $ButtonSF.Size = New-Object System.Drawing.Size(120,23)
    $ButtonSF.Text = "Submit File"
    $ButtonSF.Add_Click({
        $main_form.Close()
        return 
    })

    $main_form.Controls.Add($ButtonSF)


    #------- Horizontal Rule
    $vloc+=($vspc*1.25);
    $LabelSL = New-Object System.Windows.Forms.Label
    $LabelSL.BorderStyle = 2; #BorderStyle.Fixed3D;
    #$LabelSL.Height = 2;
    $LabelSL.Location = New-Object System.Drawing.Size($hloc,$vloc)
    $LabelSL.Size = New-Object System.Drawing.Size($gwid,2)
    $main_form.Controls.Add($LabelSL)

    #------- Preview Button
    $vloc+=($vspc/2);
    $ButtonPV = New-Object System.Windows.Forms.Button
    $ButtonPV.Location = New-Object System.Drawing.Size($hloc,$vloc)
    $ButtonPV.Size = New-Object System.Drawing.Size(120,23)
    $ButtonPV.Text = "Preview"
    $main_form.Controls.Add($ButtonPV);

    #------- Finish Up
    $main_form.ShowDialog();
}

Show-MainInterface -InArchive -CMSNumber 123412 -Discovery -Defendant "ROTTEN_Johnny_19770101.txt", 'Cruz_Elena_2002-07-15.txt', 'Harris_Jayden_1998-03-21.txt', 'Morgan_Carson_2005-11-04.txt', 'Reed_Mila_2001-01-12.txt', 'Gonzalez_Avery_2004-08-27.txt', 'Wright_Camila_1999-05-19.txt', 'Parker_Josiah_2003-09-30.txt', 'Baker_Eli_2006-12-25.txt', 'Flores_Kayla_2000-04-16.txt', 'Lee_Micah_1997-10-31.txt'