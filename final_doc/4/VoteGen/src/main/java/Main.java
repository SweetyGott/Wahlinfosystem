import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * creates fake Stimmzettel
 */
public class Main {

    public static void main(String[] args) {

        try {

            Class.forName("org.postgresql.Driver");
            Connection connection = DriverManager.getConnection(
                    "jdbc:postgresql://127.0.0.1:5432/db_proj", "postgres", "1234");

            // parameter for wk
            if (args.length > 0) {

                int i = Integer.valueOf(args[0]);

                if (0 < i && i < 300) {

                    connection.createStatement().execute("DELETE FROM db.\"Stimmzettel\" WHERE \"FkWahlkreis\" = " + i + ";");

                    createVoteForId(connection, i, 2009);
                    createVoteForId(connection, i, 2013);
                }

            } else {

                // clear database
                connection.createStatement().execute("DELETE FROM db.\"Stimmzettel\";");

                for (int i = 1; i <= 299; i++) {

                    createVoteForId(connection, i, 2009);
                    createVoteForId(connection, i, 2013);
                }
            }
            connection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void createVoteForId(Connection connection, int idWK, int year) throws Exception {

        HashMap<Integer, Integer> partyToVoteErst = new HashMap<Integer, Integer>();
        HashMap<Integer, Integer> partyToVoteZweit = new HashMap<Integer, Integer>();

        Statement stmt = connection.createStatement();

        ResultSet rsErst = stmt.executeQuery("SELECT * FROM db.\"ErgebnisseErst\" ez JOIN db.\"Parteien\" p ON ez.\"FkPartei\" = p.\"Id\" " +
                "WHERE \"FkWahlkreis\" = " + idWK + " AND \"Jahr\" = " + year + " " +
                "AND p.\"Name\" != 'Wahlberechtigte' AND p.\"Name\" != 'Wähler' AND p.\"Name\" != 'Gültige';");
        while (rsErst.next()) {

            partyToVoteErst.put(rsErst.getInt("FkPartei"), rsErst.getInt("Stimmen"));
        }

        ResultSet rsZweit = stmt.executeQuery("SELECT * FROM db.\"ErgebnisseZweit\" ez JOIN db.\"Parteien\" p ON ez.\"FkPartei\" = p.\"Id\" " +
                "WHERE \"FkWahlkreis\" = " + idWK + " AND \"Jahr\" = " + year + " " +
                "AND p.\"Name\" != 'Wahlberechtigte' AND p.\"Name\" != 'Wähler' AND p.\"Name\" != 'Gültige';");
        while (rsZweit.next()) {

            partyToVoteZweit.put(rsZweit.getInt("FkPartei"), rsZweit.getInt("Stimmen"));
        }

        ArrayList<Integer> fkPartyFst = new ArrayList<Integer>();
        ArrayList<Integer> fkPartySnd = new ArrayList<Integer>();

        for (int key : partyToVoteErst.keySet()) {

            for (int i = 0; i < partyToVoteErst.get(key); i++) {
                fkPartyFst.add(key);
            }
        }
        for (int key : partyToVoteZweit.keySet()) {

            for (int i = 0; i < partyToVoteZweit.get(key); i++) {
                fkPartySnd.add(key);
            }
        }

        System.out.println("WK + " + idWK + " year " + year);

        PreparedStatement insert = connection.prepareStatement("INSERT INTO db.\"Stimmzettel\" (\"Erststimme\",\"Zweitstimme\",\"Jahr\",\"FkWahlkreis\") VALUES (?,?,?,?)");

        for (int i = 0; i < Math.max(fkPartyFst.size(), fkPartySnd.size()); i++) {

            insert.setInt(1, (i >= fkPartyFst.size()) ? -1 : fkPartyFst.get(i));
            insert.setInt(2, (i >= fkPartySnd.size()) ? -1 : fkPartySnd.get(i));
            insert.setInt(3, year);
            insert.setInt(4, idWK);

            insert.addBatch();
        }
        insert.executeBatch();
    }


}
