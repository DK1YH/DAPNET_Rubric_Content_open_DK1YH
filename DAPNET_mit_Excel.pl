    #benutzte Module; 
    print "++++++++ Willkommen zum DAPNET-Upload-System ++++++++ \n";
    print "Lade Module \n";   
    use strict;
    use Spreadsheet::ParseExcel;
    use REST::Client;
    use MIME::Base64;
    print "Module geladen! \n";
    print "Erstelle Definitionen! \n";
    #Definitionen für das DAPNET
    my $dapnethost = 'hampager.de';
    my $dapnetport = '8080';
    my $dapnetuser = 'fillin';
    my $dapnetpw = 'fillin';	
    my $rubricName = 'yota';
    #Nachrichten, die durch dieses Programm entsandt werden
    my $zwanzigUhr = "Es ist 20 Uhr! Wir wuenschen den Lesern der Rubrik YOTA einen schoenen Abend.";
    my $schoenenTag = "Wir wuenschen einen angenehmen Tag. Bleiben Sie gesund!";
    my $schoenesWE = "Wir wuenschen den Lesern der Rubrik YOTA ein schoenes Wochenende!";
    my $info = "Rubrik-Info (YOTA): Aussendungen alle 60 Min. Inhalte an dk1yh(at)darc.de";
    #Definitionen für Excel
    my $parser   = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse('DAPNET_yota.xls');

    my $col = 3;
    my $col_min = 3;
    my $col_max = 3;
    my $row_min = 1;
    my $row_max =20;

    print "Definitionen aufgestellt! \n";

    if ( !defined $workbook ) 
    {
        die $parser->error(), ".\n";
    }
    #Heranziehen der Uhrzeit
    my $init = print "Init ";
loop :
{ 
    print "Stelle Uhrzeit fest! \n";
    (my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst) = localtime(); 
    my $time = print "Es ist: $hour,$min,$mday Uhr \n";
        #Definitionsbereich für Excel
        if ($min == 0)
        {
            print "Volle Stunde! Starte Uebertragungsprogramm! \n";
                for my $worksheet ( $workbook->worksheets() ) 
                {
                    my ( $row_min, $row_max ) = $worksheet->row_range();
                #  my ( $col_min, $col_max ) = $worksheet->col_range();
                    #TX-Slots;
                    #SLOT 1;
                    my $c = REST::Client->new();		
                    #print $c;								
                    $c->setHost("$dapnethost:$dapnetport");							
                    $c->addHeader('Authorization'=>'Basic ' . encode_base64($dapnetuser . ':' . $dapnetpw));	

                    for my $row ( 1 .. $row_max ) 
                    {
                        my $cell = $worksheet->get_cell( $row, 3 );
                        next unless $cell;

                        print "Row, Col    = ($row, 3)\n";
                        print "Value       = ", $cell->value(),       "\n";
                        #print "Unformatted = ", $cell->unformatted(), "\n";
                        print "\n";

                        my $slot1 = $cell->value();

                        sleep(3);
                        
                        my $result1=$c->POST('/news', '{"rubricName": "'.$rubricName.'", "text": "'.$slot1.'"}', {"Content-type"=>'application/json'})->responseContent();

                        print "$result1 \n";
                        print "Slot 1 erfolgreich entsandt \n";
                    }
                    if ($hour == 20,$min == 0) 
                    {
                        my $result2=$c->POST('/news', '{"rubricName": "'.$rubricName.'", "text": "'.$zwanzigUhr.'"}', {"Content-type"=>'application/json'})->responseContent();

                        print "$result2 \n";
                        print "Feierabendgruesse erfolgreich entsandt \n";

                    }
                    else
                    {
                        my $result3=$c->POST('/news', '{"rubricName": "'.$rubricName.'", "text": "'.$schoenenTag.'"}', {"Content-type"=>'application/json'})->responseContent();

                        print "$result3 \n";
                        print "Schoene-Tages-Gruesse erfolgreich entsandt \n";
            
                    }
                    if ($mday == 6,$hour == 18,$min == 0) 
                    {
                        my $result4=$c->POST('/news', '{"rubricName": "'.$rubricName.'", "text": "'.$schoenesWE.'"}', {"Content-type"=>'application/json'})->responseContent();

                        print "$result4 \n";
                        print "Wochenendgruesse erfolgreich entsandt \n";

                    }
                    if ($min == 0) 
                    {
                        my $result5=$c->POST('/news', '{"rubricName": "'.$rubricName.'", "text": "'.$info.'"}', {"Content-type"=>'application/json'})->responseContent();

                        print "$result5 \n";
                        print "Rubrik-Info erfolgreich entsandt \n";
                    }
                }
            if ($min != 0)
            {
                exit;
            }
        }
    if ($min != 0)
    {
        print "reinitilizing in 60 seconds! \n";
        sleep(60);
    }
    print "Programm abgeschlossen\n";
    redo loop;
}