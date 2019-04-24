templatevars[template]=content/template.html
templatevars[css]=$(cat << EOF
        body {
            padding: 30px;
            background-image: url('/assets/map.png');
            background-repeat: no-repeat;
            background-attachment: fixed;
        }

        h1 {
            border-bottom: .8px solid #000;
        }

        h6 {
            border-top: .8px solid #000;
        }

        .main {
            display: flex;
            flex-direction: row;
        }

        .left {
            flex: 2;
            align-self: flex-start;
        }

        .right {
            flex: 1;
            align-self: flex-end;
        }

        .code {
            background-color: #FFF;
            font-family: monospace;
            padding: 2px;
        }

        .back {
            font-size: 12pt;
        }
EOF
)
templatevars[footer]="<h6>\&copy; $(date +%Y) <a href="mailto:derek@derekarnold.net">Derek Arnold</a></h6>"

