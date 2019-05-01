package org.bverify.bverify;

import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomNavigationView;
import android.support.design.widget.TabLayout;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.MenuItem;
import android.widget.TextView;
import android.support.v7.widget.Toolbar;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import mobile.Mobile;

public class MainActivity extends AppCompatActivity implements MyProofsFragment.OnFragmentInteractionListener, VerifyFragment.OnFragmentInteractionListener {

    Handler updateHandler = new Handler();
    Runnable updateRunnable = new Runnable() {

        @Override
        public void run() {
            updateStatus();
            updateHandler.postDelayed(this, 2000);
        }
    };


    public void onFragmentInteraction(Uri uri) {
        // Do nothing for now
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        try {
            mobile.Mobile.setDataDir(this.getApplicationContext().getFilesDir().toString());
            mobile.Mobile.runBVerifyClient("bverify.org",15901);
        } catch (Exception ex) {
            Log.e("BVerifyMobile", ex.toString());
        }

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        TabLayout tabLayout =
                (TabLayout) findViewById(R.id.tab_layout);

        tabLayout.addTab(tabLayout.newTab().setText("My Proofs").setIcon(R.drawable.myproofs));
        tabLayout.addTab(tabLayout.newTab().setText("Verify Proof").setIcon(R.drawable.verifyproof));

        final ViewPager viewPager =
                (ViewPager) findViewById(R.id.pager);
        final PagerAdapter adapter = new BVerifyPagerAdapter
                (getSupportFragmentManager(),
                        tabLayout.getTabCount());
        viewPager.setAdapter(adapter);

        viewPager.addOnPageChangeListener(new
                TabLayout.TabLayoutOnPageChangeListener(tabLayout));
        tabLayout.setOnTabSelectedListener(new
                                               TabLayout.OnTabSelectedListener() {
                                                   @Override
                                                   public void onTabSelected(TabLayout.Tab tab) {
                                                       viewPager.setCurrentItem(tab.getPosition());
                                                   }

                                                   @Override
                                                   public void onTabUnselected(TabLayout.Tab tab) {

                                                   }

                                                   @Override
                                                   public void onTabReselected(TabLayout.Tab tab) {

                                                   }

                                               });




        updateHandler.postDelayed(updateRunnable, 0);
    }

    @Override
    public void onPause() {
        super.onPause();
        updateHandler.removeCallbacks(updateRunnable);
    }

    private void updateStatus() {

        final TextView syncText = (TextView)findViewById(R.id.syncText);

        //creating a string request to send request to the url
        StringRequest stringRequest = new StringRequest(Request.Method.GET, "http://127.0.0.1:8001/status",
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        try {
                            //getting the whole json object from the response
                            JSONObject obj = new JSONObject(response);

                            boolean synced = obj.getBoolean("synced");
                            int blocks = obj.getInt("blockHeight");

                            syncText.setText(String.format("%s (%d blocks)", synced ? "Synced" : "Syncing", blocks));
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                },
                new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        //displaying the error in toast if occurrs
                        Toast.makeText(getApplicationContext(), error.getMessage(), Toast.LENGTH_SHORT).show();
                    }
                });

        //creating a request queue
        RequestQueue requestQueue = Volley.newRequestQueue(this);

        //adding the string request to request queue
        requestQueue.add(stringRequest);
    }

}
