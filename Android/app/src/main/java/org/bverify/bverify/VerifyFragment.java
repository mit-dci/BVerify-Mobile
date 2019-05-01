package org.bverify.bverify;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.google.android.gms.vision.barcode.Barcode;
import com.notbytes.barcode_reader.BarcodeReaderActivity;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link VerifyFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link VerifyFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class VerifyFragment extends Fragment {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    private static final int BARCODE_READER_ACTIVITY_REQUEST = 19218;



    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    private OnFragmentInteractionListener mListener;

    public VerifyFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment VerifyFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static VerifyFragment newInstance(String param1, String param2) {
        VerifyFragment fragment = new VerifyFragment();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }


    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment

        View view = inflater.inflate(R.layout.fragment_verify, container, false);

        final View detailsView = view.findViewById(R.id.detailsLayout);
        Button scanButton = (Button)(view.findViewById(R.id.scanButton));
        scanButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                detailsView.setVisibility(View.GONE);
                scanProof();
            }
        });

        return view;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (resultCode != Activity.RESULT_OK) {
            Toast.makeText(getContext(), "error in  scanning", Toast.LENGTH_SHORT).show();
            return;
        }

        if (requestCode == BARCODE_READER_ACTIVITY_REQUEST && data != null) {
            final Barcode barcode = data.getParcelableExtra(BarcodeReaderActivity.KEY_CAPTURED_BARCODE);

            StringRequest stringRequest = new StringRequest(Request.Method.POST, "http://localhost:8001/verifyonce", new Response.Listener<String>() {
                @Override
                public void onResponse(String response) {
                    try {
                        JSONObject jsonObject = new JSONObject(response);
                        boolean valid = jsonObject.getBoolean("Valid");
                        if (valid) {
                            ((TextView)getView().findViewById(R.id.statement)).setText(jsonObject.getString("Statement"));
                            ((TextView)getView().findViewById(R.id.signedBy)).setText(jsonObject.getString("PubKey"));
                            ((TextView)getView().findViewById(R.id.valid)).setText("OK");
                            ((TextView)getView().findViewById(R.id.blockHash)).setText(jsonObject.getString("BlockHash"));
                            ((TextView)getView().findViewById(R.id.commitmentTransaction)).setText(jsonObject.getString("TxHash"));
                            java.util.Date time=new java.util.Date(jsonObject.getLong("BlockTimestamp")*1000);

                            ((TextView)getView().findViewById(R.id.blockTimestamp)).setText(time.toString());
                        } else {
                            ((TextView)getView().findViewById(R.id.statement)).setText(">> Invalid Statement <<");
                            ((TextView)getView().findViewById(R.id.signedBy)).setText("");
                            ((TextView)getView().findViewById(R.id.valid)).setText("Invalid: " + jsonObject.getString("Error"));
                            ((TextView)getView().findViewById(R.id.blockHash)).setText("");
                            ((TextView)getView().findViewById(R.id.commitmentTransaction)).setText("");
                            ((TextView)getView().findViewById(R.id.blockTimestamp)).setText("");
                        }

                        getView().findViewById(R.id.detailsLayout).setVisibility(View.VISIBLE);


                    } catch (JSONException e){
                        e.printStackTrace();
                    }
                }
            }, new Response.ErrorListener() {
                @Override
                public void onErrorResponse(VolleyError error) {

                }
            }){
                @Override
                public byte[] getBody() throws AuthFailureError {
                    return barcode.rawValue.getBytes();
                }
            };
            //creating a request queue
            RequestQueue requestQueue = Volley.newRequestQueue(getContext());

            //adding the string request to request queue
            requestQueue.add(stringRequest);
        }

    }

    private void scanProof() {
        Intent launchIntent = BarcodeReaderActivity.getLaunchIntent(getContext(), true, false);
        startActivityForResult(launchIntent, BARCODE_READER_ACTIVITY_REQUEST);
    }

    // TODO: Rename method, update argument and hook method into UI event
    public void onButtonPressed(Uri uri) {
        if (mListener != null) {
            mListener.onFragmentInteraction(uri);
        }
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnFragmentInteractionListener) {
            mListener = (OnFragmentInteractionListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnFragmentInteractionListener");
        }

    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     * <p>
     * See the Android Training lesson <a href=
     * "http://developer.android.com/training/basics/fragments/communicating.html"
     * >Communicating with Other Fragments</a> for more information.
     */
    public interface OnFragmentInteractionListener {
        // TODO: Update argument type and name
        void onFragmentInteraction(Uri uri);
    }
}
